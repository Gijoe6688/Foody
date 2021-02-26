-- step 1: structure
DROP DATABASE IF EXISTS Foody;
CREATE DATABASE Foody;
USE Foody;

CREATE TABLE categorie (
CodeCateg integer primary key NOT NULL, 
NomCateg varchar(25) NOT NULL, 
Descriptionn varchar(100)
);

CREATE TABLE messager (
NoMess integer primary key NOT NULL, 
NomMess varchar(25) NOT NULL, 
Tel varchar(25) NOT NULL
);

CREATE TABLE client (
CodeCli char(5) primary key NOT NULL, 
Societe varchar(100), 
Contact varchar(25) NOT NULL, 
Fonction varchar(100), 
Adresse varchar(100), 
Ville varchar(25), 
Region varchar(25), 
Codepostal varchar(25),
Pays varchar(25), 
Tel varchar(25), 
Fax varchar(25)
);

CREATE TABLE fournisseur (
NoFour integer primary key NOT NULL, 
Societe varchar(100) NOT NULL, 
Contact varchar(100) NOT NULL, 
Fonction varchar(100), 
Adresse varchar(100), 
Ville varchar(25), 
Region varchar(25),
CodePostal varchar(25), 
Pays varchar(25), 
Tel varchar(25), 
Fax varchar(25), 
PageAccueil varchar(100)
);

CREATE TABLE employe (
NoEmp integer primary key, 
Nom varchar(25) NOT NULL, 
Prenom varchar(25) NOT NULL, 
Fonction varchar(25) NOT NULL, 
TitreCourtoisie varchar(25), 
DateNaissance date,
DateEmbauche date, 
Adresse varchar(50), 
Ville varchar(25), 
Region varchar(25), 
Codepostal varchar(25), 
Pays varchar(25), 
TelDom varchar(25), 
Extension int,
RendCompteA int
-- constraint fk_employe foreign key (RendCompteA) references employe (NoEmp)
-- foreign key (RendCompteA) references employe (NoEmp)
);
 
CREATE TABLE produit (
RefProd integer primary key NOT NULL, 
NomProd varchar(100) NOT NULL, 
NoFour integer NOT NULL, 
CodeCateg integer NOT NULL, 
QteParUnit varchar(25), 
PrixUnit decimal(10,2),
UnitesStock integer, 
UnitesCom integer, 
NiveauReap int, 
Indisponible int,
foreign key (NoFour) references fournisseur (NoFour),
foreign key (CodeCateg) references categorie (CodeCateg)
);

CREATE TABLE Commande (
NoCom integer primary key NOT NULL, 
CodeCli char(5) NOT NULL, 
NoEmp integer NOT NULL, 
DateCom date NOT NULL, 
ALivAvant date, 
DateEnv date, 
NoMess integer NOT NULL,
Portt float, 
Destinataire varchar(100) NOT NULL, 
AdrLiv varchar(100) NOT NULL, 
VilleLiv varchar(25) NOT NULL, 
RegionLiv varchar(25), 
CodePostalLiv varchar(25), 
PaysLiv varchar(25) NOT NULL,
foreign key (CodeCli) references client (CodeCli),
foreign key (NoEmp) references employe (NoEmp),
foreign key (NoMess) references messager (NoMess)
);

CREATE TABLE detailsCommande (
NoCom integer NOT NULL, 
RefProd integer NOT NULL, 
PrixUnit decimal(10,2), 
Qte integer, 
Remise decimal(3,2),
primary key (NoCom, RefProd),
foreign key (NoCom) references commande (NoCom),
foreign key (RefProd) references produit (RefProd)
);
-- step 2 insert les données from csv 

-- step 3 ajouter foreign key pour table employe

alter table employe add constraint fk_employe foreign key (RendCompteA) references employe(NoEmp);