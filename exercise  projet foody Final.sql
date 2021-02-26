use foody;

-- page 8
-- 1.Lister les clients français installés à Paris dont le numéro de fax n'est pas renseigné
SELECT * FROM client WHERE ville = 'Paris' and fax is null;

-- 2.Lister les clients français, allemands et canadiens
SELECT * FROM client WHERE Pays IN ('France', 'Allemagne','Canada');

-- 3.Lister les clients dont le nom de société contient "restaurant"
SELECT * FROM client WHERE Societe LIKE '%restaurant%';

-- --------------------------------------------------------------------------
-- page 9
-- 1.Lister les descriptions des catégories de produits (table Categorie)
SELECT descriptionn FROM categorie;

-- 2.Lister les différents pays et villes des clients, le tout trié par ordre alphabétique croissant du pays et décroissant de la ville
SELECT ville,pays FROM client ORDER BY pays ASC, ville DESC;

-- 3.Lister tous les produits vendus en bouteilles (bottle) ou en canettes(can)
SELECT * FROM produit WHERE QteParUnit LIKE '%bottle%' or QteParUnit LIKE '%can%';

-- 4.Lister les fournisseurs français, en affichant uniquement le nom, le contact et la ville, triés par ville
SELECT Societe, Contact, Ville FROM fournisseur
WHERE pays = 'France'
ORDER BY ville;

/* 5.Lister les produits (nom en majuscule et référence) du fournisseur n° 8 dont le prix unitaire est entre 10 et 100 euros, 
   en renommant les attributs pour que ça soit explicite*/
select  RefProd, upper(NomProd), PrixUnit as 'PrixUnit(10 à 100 euros)' from produit Where (NoFour=8) and (PrixUnit between 10 and 100);

-- 6.Lister les numéros d'employés ayant réalisé une commande (cf table Commande) à livrer en France, à Lille, Lyon ou Nantes
select NoEmp from commande where PaysLiv='France' and VilleLiv in ('Lille','Lyon','Nantes'); 

/* 7.Lister les produits dont le nom contient le terme "tofu" ou le terme "choco", 
dont le prix est inférieur à 100 euros (attention à la condition à écrire)*/
select * from produit where (NomProd like '%tofu%' or NomProd like '%choco%') and PrixUnit<100;

-- ---------------------------------------------------------------------------------------------
-- page 10
/* La table DetailsCommande contient l'ensemble des lignes d'achat de chaque commande. 
   Calculer, pour la commande numéro 10251, pour chaque produit acheté dans celle-ci, 
   le montant de la ligne d'achat en incluant la remise (stockée en proportion dans la table). 
   Afficher donc (dans une même requête) :
- le prix unitaire,
- la remise,
- la quantité,
- le montant de la remise,
- le montant à payer pour ce produit */
select PrixUnit, Remise, Qte, round(PrixUnit*Qte*Remise,2) as montant_remise, round(PrixUnit*Qte*(1-Remise),2) as proportion from detailscommande where NoCom=10251;

-- --------------------------------------------------------------------------------
-- page 13
/* 1.A partir de la table Produit, afficher "Produit non disponible" lorsque l'attribut Indisponible vaut 1, et "Produit disponible" sinon. */
select *,
	case 
		when Indisponible=1 then "Produit non disponible"
        else "Produit disponible"
	end as "info disponible"
from Produit;

/* 2.À partir de la table DetailsCommande, indiquer les infos suivantes en fonction de la remise
si elle vaut 0 : "aucune remise"
si elle vaut entre 1 et 5% (inclus) : "petite remise"
si elle vaut entre 6 et 15% (inclus) : "remise modérée"
sinon :"remise importante" */
select *,
	case 
		when (Remise=0) then "aucune remise"
        when (Remise<0.06) then "petite remise"
        when (Remise<0.16) then "remise modérée"
        else "remise importante"
	end as "fonction de la remise"
from detailscommande;

/* 3.Indiquer pour les commandes envoyées si elles ont été envoyées 
en retard (date d'envoi DateEnv supérieure (ou égale) à la date butoir ALivAvant) ou à temps  */
select NoCom, DateEnv, AlivAvant,
	case
		when DateEnv is null then "pas encore envoyées"
		when (DateEnv>=AlivAvant) then "envoyées en retard"
        else "envoyées à temps"
	end as "info envoyées"
from commande;

-- ---------------------------------------------------------------------------------------------------
-- page 14 Fonctions sur chaînes de caractères
/* Dans une même requête, sur la table Client :
* Concaténer les champs Adresse, Ville, CodePostal et Pays dans un nouveau champ nommé Adresse_complète, 
  pour avoir : Adresse, CodePostal, Ville, Pays
* Extraire les deux derniers caractères des codes clients
* Mettre en minuscule le nom des sociétés
* Remplacer le terme "Owner" par "Freelance" dans Fonction
* Indiquer la présence du terme "Manager" dans Fonction */
select concat(Adresse,',   ',CodePostal,'   ',Ville,',   ',Pays) as Adresse_complète, 
	right(CodeCli,2) as last_2_char_CodeCli, 
    lower(Societe) as Societe,
    replace(Fonction,"Owner","Freelance") as "Foction change terme",
    case
		when Fonction like "%Manager%" then "Manager"
		else "no"
	end as "Fonction avec Manager"
from Client;

-- ----------------------------------------------------------------------------------------------------------
-- page 14 fonction sur les dates
-- 1.Afficher le jour de la semaine en lettre pour toutes les dates de commande, afficher "week-end" pour les samedi et dimanche,
select DateCom,
	case
		when weekday(DateCom) in(5,6) then "week-end"
		else dayname(DateCom)
    end as "jour de la semaine"
from commande;

/* 2.Calculer le nombre de jours entre la date de la commande (DateCom) et la date butoir de livraison (ALivAvant), 
pour chaque commande, On souhaite aussi contacter les clients 1 mois après leur commande. 
ajouter la date correspondante pour chaque commande */
select NoCom,DateCom,ALivAvant, datediff(ALivAvant,DateCom) as "jour diff", date_add(DateCom, interval 1 month) as "date contact client(1mois apres commmande)" from commande;

-- ----------------------------------------------------------------------
-- page 15 Bonus
-- 1.Récupérer l'année de naissance et l'année d'embauche des employés
select NoEmp, DateNaissance, year(DateNaissance) as "year de naissance", DateEmbauche, year(DateEmbauche) as "year de embauche" from employe;

-- 2.Calculer à l'aide de la requête précédente l'âge d'embauche et le nombre d'années dans l'entreprise
-- solution 1
select NoEmp, DateNaissance, timestampdiff(year,DateNaissance,DateEmbauche) as "age d'embauche", DateEmbauche, timestampdiff(year,DateEmbauche,now()) as "le nombre d'années dans l'entreprise" from employe;
-- solution 2 
select NoEmp, DateNaissance, floor(datediff(DateEmbauche,DateNaissance)/365) as "age d'embauche", DateEmbauche, floor(datediff(now(),DateEmbauche)/365) as "le nombre d'années dans l'entreprise" from employe;

-- 3.Afficher le prix unitaire original, la remise en pourcentage, le montant de la remise et le prix unitaire avec remise (tous deux arrondis aux centimes), pour les lignes de commande dont la remise est strictement supérieure à 10%
select PrixUnit, round(Remise*100) as "Remise%", round(PrixUnit*Remise,2) as "montant remise/unit", round(PrixUnit*Qte*Remise,2) as "montant de la remise" from detailscommande where Remise>0.1;

-- 4.Calculer le délai d'envoi (en jours) pour les commandes dont l'envoi est après la date butoir, ainsi que le nombre de jours de retard
select NoCom,date(DateCom),date(ALivAvant),date(DateEnv), datediff(DateEnv,ALivAvant) as "jour retard" from commande where datediff(DateEnv,ALivAvant)>0;

-- 5.Rechercher les sociétés clientes, dont le nom de la société contient le nom du contact de celle-ci
select CodeCli,Societe,Contact from client where Societe like concat("%",Contact,"%");

-- --------------------------------------------------------------------------
-- page 16 Aggrégats
-- 1.Calculer le nombre d'employés qui sont "Sales Manager"
select NoEmp,Fonction,count(*) from employe where Fonction="Sales Manager";

-- 2.Calculer le nombre de produits de moins de 50 euros
select count(*) from produit where PrixUnit<50;

-- 3.Calculer le nombre de produits de catégorie 2 et avec plus de 10 unités en stocks
select count(*) from produit where CodeCateg=2 and UnitesStock>10;

-- 4.Calculer le nombre de produits de catégorie 1, des fournisseurs 1 et 18
select count(*) from produit where CodeCateg=1 and NoFour in (1,18);

-- 5.Calculer le nombre de pays différents de livraison
select count(distinct PaysLiv) from commande;

-- pays de client et different pays livraison
select * from commande left join client using(CodeCli) where  not(commande.PaysLiv=client.Pays);

-- 6.Calculer le nombre de commandes réalisées le en Aout 2006.
select count(*) from commande where DateCom like "2006-08%";

-- ---------------------------------------------------------------------------
-- page 17
/* 1.Calculer le coût du port minimum et maximum des commandes , 
	ainsi que le coût moyen du port pour les commandes du client dont le code est "QUICK" (attribut CodeCli)*/
select min(Portt) as "port minimum", max(Portt) as "port maximum", round(avg(Portt),2) as "port moyen" from commande where CodeCli="QUICK";
    
-- 2.Pour chaque messager (par leur numéro : 1, 2 et 3), donner le montant total des frais de port leur correspondant
select NoMess, round(sum(Portt),2) as "montant total frais port"  from commande group by NoMess;

-- -----------------------------------------------------------------------------
-- page 19
-- 1.Donner le nombre d'employés par fonction
select fonction,count(*) from employe group by fonction;

-- 2.Donner le montant moyen du port par messager(shipper)
select NoMess,round(avg(Portt),2) as "moyen du port par messager" from commande group by NoMess;

-- 3.Donner le nombre de catégories de produits fournis par chaque fournisseur
select NoFour,count(distinct CodeCateg) from produit group by NoFour;

-- 4.Donner le prix moyen des produits pour chaque fournisseur et chaque catégorie de produits fournis par celui-ci
select NoFour, CodeCateg, round(avg(PrixUnit),2) as "prix moyen des produits" from produit group by NoFour, CodeCateg;

-- ------------------------------------------------------------------------------
-- page 20
-- 1.Lister les fournisseurs ne fournissant qu'un seul produit
select NoFour, fournisseur.Societe,count(distinct NomProd) as nombre_produit from produit left join fournisseur using (NoFour) group by NoFour having count(distinct NomProd)=1;

-- 2.Lister les catégories dont les prix sont en moyenne supérieurs strictement à 50 euros
-- solution 1 pour question 2 (page 20)
select CodeCateg, categorie.NomCateg, round(avg(PrixUnit),2) as "prix moyen/categorie" from produit left join categorie using(CodeCateg) group by CodeCateg having avg(PrixUnit)>50;
-- solution 2 pour question 2 (page 20)
select CodeCateg, categorie.NomCateg, round(avg(PrixUnit),2) as "prix moyen/categorie" from produit join categorie using(CodeCateg) group by CodeCateg having avg(PrixUnit)>50;

-- 3.Lister les fournisseurs ne fournissant qu'une seule catégorie de produits
select NoFour, fournisseur.Societe from produit left join fournisseur using(NoFour) group by NoFour having count(distinct CodeCateg)=1;

-- 4.Lister le Products le plus cher pour chaque fournisseur, pour les Products de plus de 50 euro
select * from produit  where (NoFour,PrixUnit) in (select NoFour,max(PrixUnit) from produit group by NoFour) and PrixUnit>50 order by NoFour;

-- ----------------------------------------------------------------------------
-- Bonus page 21:
-- 1.Donner la quantité totale commandée par les clients, pour chaque produit
select RefProd, produit.NomProd,sum(Qte) from detailscommande left join produit using(RefProd)  group by RefProd order by RefProd;

-- 2.Donner les cinq clients avec le plus de commandes, triés par ordre décroissant
select CodeCli, client.Societe, count(NoCom) as n_commandes from commande left join client using(CodeCli) group by CodeCli order by count(NoCom) DESC limit 5;

-- 3.Calculer le montant total des lignes d'achats de chaque commande, sans et avec remise sur les produits
select *, round(PrixUnit*Qte,2) as "montant total", round(PrixUnit*Qte*(1-Remise),2) as "montant total avec remise" from detailscommande;

-- 4.Pour chaque catégorie avec au moins 10 produits, calculer le montant moyen des prix
select CodeCateg , round(avg(PrixUnit),2) as "moyen des prix" from produit group by CodeCateg having count(*)>=10;

-- 5.Donner le numéro de l'employé ayant fait le moins de commandes
select NoEmp from employe left join commande using(NoEmp) group by NoEmp order by count(NoCom) limit 1;

-- ----------------------------------------------------------------------------


#EXERCICE 11: (p22)
#1.Récupérer les informations des fournisseurs pour chaque produit
SELECT NomProd, fournisseur.* 
FROM produit
LEFT JOIN fournisseur
USING (NoFour);

#2.Afficher les informations des commandes du client "Lazy K Kountry Store"
SELECT commande.* FROM commande
where CodeCli in (select CodeCli from client where societe = "Lazy K Kountry Store");

#3.Afficher le nombre de commande pour chaque messager (en indiquant son nom)
-- solution 1
SELECT messager.NoMess ,Messager.NomMess, COUNT(DISTINCT Commande.NoCom) AS "nb_commande/messager" 
FROM Messager, Commande
WHERE messager.NoMess= commande.NoMess
GROUP BY NomMess;
-- solution 2 avec join
SELECT NoMess,NomMess, COUNT(DISTINCT Commande.NoCom) AS "nb_commande/messager" 
FROM Messager
LEFT JOIN Commande
USING (NoMess)
GROUP BY NoMess;



-- -----------------------------------------------------------------------------------------
#EXERCICE 12: (p24)
#1.Récupérer les informations des fournisseurs pour chaque produit, avec une jointure interne
SELECT NomProd, fournisseur.* 
FROM produit
JOIN fournisseur
USING (NoFour); 

#2.Afficher les informations des commandes du client "Lazy K Kountry Store", avec une jointure interne
SELECT commande.* FROM commande
JOIN client USING (CodeCli)
WHERE client.societe = "Lazy K Kountry Store";

#3.Afficher le nombre de commande pour chaque messager (en indiquant son nom), avec une jointure interne
SELECT NoMess,NomMess, COUNT(DISTINCT Commande.NoCom) AS "nb_commande/messager" 
FROM Messager
JOIN Commande
USING (NoMess)
GROUP BY NoMess; 

-- -------------------------------------------------------------------------------------------------------
#EXERCICE 13: (p26)
#1.Compter pour chaque produit, le nombre de commandes où il apparaît, même pour ceux dans aucune commande
select RefProd, NomProd, count( distinct NoCom) as "nombre de commandes" from produit left join detailscommande using(RefProd) group by RefProd;

#2.Lister les produits n'apparaissant dans aucune commande
select produit.* from produit where RefProd not in (select RefProd from detailscommande);

#3.Existe-t'il un employé n'ayant enregistré aucune commande ? 
select NoEmp, Nom from employe where NoEmp not in (select NoEmp from commande);


-- -----------------------------------------------------------------------------------------
#EXERCICE 14: (p28)
#1.Récupérer les informations des fournisseurs pour chaque produit, avec jointure à la main
SELECT produit.NomProd, fournisseur.* 
FROM fournisseur, produit
WHERE fournisseur.NoFour = produit.NoFour;
-- GROUP BY NomProd;

-- .......................
#2.Afficher les informations des commandes du client "Lazy K Kountry Store", avec jointure à la main
SELECT client.societe, commande.* FROM commande,client
WHERE commande.CodeCli = client.CodeCli AND client.societe = "Lazy K Kountry Store";

-- ......................
#3.Afficher le nombre de commande pour chaque messager (en indiquant son nom), avec jointure à la main
SELECT Messager.NomMess, COUNT(Commande.NoCom) AS "nb_commande/messager" 
FROM Messager, Commande
WHERE messager.NoMess = commande.NoMess
GROUP BY commande.NoMess; 


-- ----------------------------------------------------------------------------
-- page 28
-- Bonus :
-- 1.Compter le nombre de produits par fournisseur
select NoFour,count(distinct NomProd) as n_produit from produit group by NoFour;

-- 2.Compter le nombre de produits par pays d'origine des fournisseurs
select fournisseur.Pays, count(*) as n_produit from produit left join fournisseur using(NoFour) group by fournisseur.Pays order by fournisseur.Pays;

-- 3.Compter pour chaque employé le nombre de commandes gérées, même pour ceux n'en ayant fait aucune
select NoEmp, employe.nom, employe.prenom, count(commande.NoCom)  as nombre_commandes 
from employe 
left join commande
using(NoEmp)
group by NoEmp;
-- solution 2 right join
select NoEmp, employe.nom, employe.prenom, count(NoCom) as nombre_commandes 
from commande 
right join employe
using(NoEmp)
group by NoEmp;

-- 4.Afficher le nombre de pays différents des clients pour chaque employe (en indiquant son nom et son prénom)
select NoEmp,Nom,Prenom, count(distinct client.Pays)  as pays 
from employe 
left join commande
using(NoEmp)
left join client
using(CodeCli)
group by NoEmp;

-- 5.Compter le nombre de produits commandés pour chaque client pour chaque catégorie
select produit.CodeCateg, CodeCli, client.Societe,count(distinct NomProd) as nobre_produits_commande
from commande 
right join detailscommande using (NoCom) 
left join produit using(RefProd)
left join client using(CodeCli)  
group by produit.CodeCateg, CodeCli
order by produit.CodeCateg, CodeCli;

-- ------------------------------------------------------------------------------
-- page 30
-- Exercices
-- 1.Lister les employés n'ayant jamais effectué une commande, via une sous-requête
select * from employe where NoEmp not in (select NoEmp from commande where NoEmp=employe.NoEmp);
-- solution avec not exists
select * from employe where not exists (select * from commande where NoEmp=employe.NoEmp);

-- 2.Nombre de produits proposés par la société fournisseur "Ma Maison", via une sous-requête
select count(*) as n_produits from produit where NoFour in (select NoFour from fournisseur where fournisseur.Societe="Ma Maison");

-- 3.Nombre de commandes passées par des employés sous la responsabilité de "Buchanan Steven"
select count(*) as n_commandes from commande where NoEmp in (select NoEmp from employe where RendCompteA in (select NoEmp from employe where Nom="Buchanan" and Prenom="Steven"));

-- ---------------------------------------------------------------------------------
-- page 31
-- Exercices
-- 1.Lister les produits n'ayant jamais été commandés, à l'aide de l'opérateur EXISTS
select * from produit where not exists (select * from detailscommande where RefProd=produit.RefProd);

-- 2.Lister les fournisseurs dont au moins un produit a été livré en France
select * 
	from fournisseur 
	where exists (select * 
					from produit 
					where NoFour=fournisseur.NoFour 
					and exists (select * 
									from detailscommande 
									where RefProd=produit.RefProd 
                                    and exists (select * 
													from commande 
													where NoCom=detailscommande.NoCom 
                                                    and PaysLiv="France") ) );
                                                    
-- 3.Liste des fournisseurs qui ne proposent que des boissons (drinks)
select * from fournisseur f where exists (select * from produit p where NoFour=f.NoFour and exists (select * from categorie where CodeCateg=p.CodeCateg and NomCateg="drinks" ));

-- -----------------------------------------------------------------------------------
-- Bonus page 31 :
-- 1.Lister les clients qui ont commandé du "Camembert Pierrot" (sans aucune jointure)
select * 
	from client 
	where exists(select * 
					from commande 
                    where CodeCli=client.CodeCli 
                    and exists(select * 
								from detailscommande 
                                where NoCom=commande.NoCom 
                                and exists (select * 
												from produit 
												where RefProd=detailscommande.RefProd 
												and NomProd="Camembert Pierrot")));

-- 2.Lister les fournisseurs dont aucun produit n'a été commandé par un client français
select * 
	from fournisseur 
    where not exists(select * 
						from produit 
                        where NoFour=fournisseur.NoFour 
                        and exists(select * 
									from detailscommande 
                                    where RefProd=produit.RefProd 
                                    and exists(select * 
												from commande 
                                                where NoCom=detailscommande.NoCom 
                                                and exists(select * 
															from client 
                                                            where CodeCli=commande.CodeCli 
                                                            and Pays="France"))));
                                                            
-- 3.Lister les clients qui ont commandé tous les produits du fournisseur "Exotic liquids"
-- solution 1  
select client.* 
from client
join commande using(CodeCli)
join detailscommande using(NoCom)
where exists (select * from produit where RefProd=detailscommande.RefProd and exists(select* from fournisseur where NoFour=produit.NoFour and Societe="Exotic liquids"))
group by CodeCli
having count(distinct detailscommande.RefProd)=(select count(*) from produit where exists(select* from fournisseur where NoFour=produit.NoFour and Societe="Exotic liquids"));
-- solution 2  
select client.*,produit.NoFour as NoFour_commandé,count(distinct detailscommande.RefProd) as n_produits_NoFour1_commandé
from client 
join commande using (CodeCli)
join detailscommande using (NoCom) 
join produit using(RefProd)
where exists(select* from fournisseur where NoFour=produit.NoFour and  Societe="Exotic liquids")
group by CodeCli
having count(distinct detailscommande.RefProd)=(select count(*) from produit where exists(select* from fournisseur where NoFour=produit.NoFour and Societe="Exotic liquids"));
-- solution 3 
select client.*
from client 
join commande using (CodeCli)
right join detailscommande using (NoCom) 
join produit using(RefProd)
where exists(select* from fournisseur where NoFour=produit.NoFour and  Societe="Exotic liquids")
group by CodeCli
having count(distinct detailscommande.RefProd)=(select count(*) from produit where exists(select* from fournisseur where NoFour=produit.NoFour and Societe="Exotic liquids"));

-- 4.Quel est le nombre de fournisseurs n’ayant pas de commandes livrées au Canada ?
select count(*) 
from fournisseur
where NoFour not in (select Nofour 
						from produit 
						right join detailscommande using(RefProd)
						join commande using (NoCom)
						where commande.PaysLiv="Canada");

-- 5.Lister les employés ayant une clientèle sur tous les pays
select employe.* 
from employe
join commande using(NoEmp)
join client using(CodeCli)
group by NoEmp
having count(distinct client.Pays)=(select count(distinct Pays) from client);

-- --------------------------------------------------------------------------
-- page 32 - 33
-- Exercices
-- En utilisant la clause UNION :
-- 1.Lister les employés (nom et prénom) étant "Representative" ou étant basé au Royaume-Uni (UK)
select Nom,Prenom from employe where Fonction like "%Representative%"
union
select Nom,Prenom from employe where Pays="UK";

-- 2.Lister les clients (société et pays) ayant commandés via un employé situé à Londres ("London" pour rappel) ou ayant été livré par "Speedy Express"
select * from client where CodeCli in (select CodeCli from commande where NoEmp in (select NoEmp from employe where Ville="London"))
union
select * from client where CodeCli in (select CodeCli from commande where NoMess in (select NoMess from messager where NomMess="Speedy Express"));

-- ----------------------------------------------------------------------------
-- page 33
-- Exercices
-- 1.Lister les employés (nom et prénom) étant "Representative" et étant basé au Royaume-Uni (UK)
select Nom,Prenom from employe where Fonction like "%Representative%" and Pays="UK";

-- 2.Lister les clients (société et pays) ayant commandés via un employé basé à "Seattle" et ayant commandé des "Desserts"
select * 
from client 
where CodeCli in (select CodeCli from commande where NoEmp in (select NoEmp from employe where Ville="Seattle"))
and CodeCli in (select CodeCli from commande where NoCom in (select NoCom from detailscommande where RefProd in (select RefProd from produit where CodeCateg in (select CodeCateg from categorie where NomCateg="Desserts"))));


-- page 34
-- Exercices
-- 1.Lister les employés (nom et prénom) étant "Representative" mais n'étant pas basé au Royaume-Uni (UK)
select * from employe where (Fonction like "%Representative%") and (not Pays="UK");

-- 2.Lister les clients (société et pays) ayant commandés via un employé situé à Londres ("London" pour rappel) et n'ayant jamais été livré par "United Package"
select * 
from client 
where CodeCli in (select CodeCli from commande where NoEmp in (select NoEmp from employe where Ville="London"))
and CodeCli not in (select CodeCli from commande where NoMess in (select NoMess from messager where NomMess="United Package"));

-- --------------------------------------------------------------------------------------------------------------------
-- Bonus :
-- 1.Lister les employés ayant déjà pris des commandes de "Boissons" ou ayant envoyés une commande via "Federal Shipping"
-- solution 1
select * 
from employe 
where NoEmp in (select NoEmp from commande where NoCom in (select NoCom from detailscommande where RefProd in (select RefProd from produit where CodeCateg in (select CodeCateg from categorie where NomCateg="Boissons"))))
or NoEmp in (select NoEmp from commande where NoMess in (select NoMess from messager where NomMess="Federal Shipping"));
-- solution 2
select * 
from employe 
where NoEmp in (select NoEmp from commande where NoCom in (select NoCom from detailscommande where RefProd in (select RefProd from produit where CodeCateg in (select CodeCateg from categorie where NomCateg="Boissons"))))
union
select * 
from employe
where NoEmp in (select NoEmp from commande where NoMess in (select NoMess from messager where NomMess="Federal Shipping"))
order by NoEmp;

-- 2.Lister les produits de fournisseurs canadiens et ayant été commandé par des clients du "Canada"
select * from produit 
where NoFour in (select NoFour from fournisseur where Pays="Canada") 
and RefProd in (select RefProd from detailscommande where NoCom in (select NoCom from commande where CodeCli in (select CodeCli from client where Pays="Canada")));

-- 3.Lister les clients (Société) qui ont commandé du "Konbu" mais pas du "Tofu"
select * from client
where CodeCli in (select CodeCli from commande where NoCom in (select NoCom from detailscommande where RefProd in (select RefProd from produit where NomProd="Konbu")))
and CodeCli not in (select CodeCli from commande where NoCom in (select NoCom from detailscommande where RefProd in (select RefProd from produit where NomProd="Tofu")))
