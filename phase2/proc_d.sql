/*Créer une fonction stockée qui prend en paramètre le nom d’une série de BD et
qui renvoie les clients ayants acheté tous les albums de la série (utiliser des
boucles FOR et/ou des curseurs).
Si aucun client ne répond à la requête alors on affichera un message
d’avertissement ‘Aucun client n’a acheté tous les exemplaires de la série %’, en
complétant le ‘ %’ par le nom de la série.*/
Create or replace function proc_d (nom_serie_param Serie.nomSerie%TYPE)
returns setOf Client
As $$
  Declare
    ncli Client.numClient%TYPE;
    clientRet Client%ROWTYPE;
    compareTable int;
  Begin
    Drop view if exists vue_proc_d cascade;    
    Create view vue_proc_d as
    Select isbn
    From  BD b join Serie s on s.numSerie = b.numSerie
    Where nomSerie = nom_serie_param;

    for ncli in Select * from Client
    loop
      Select count(*) into compareTable
      From (Select isbn
            From Vente join Concerner c1 on c1.numVente = v.numVente
            Where numClient=ncli
            Order by isbn
            Minus
            Select * from vue_proc_d Order by isbn;
            )
      if compareTable = 0 then
        Select * into clientRet from Client Where numClient = ncli;
      enf if;
      return next clientRet;
    end loop;
    return;
  End
$$ Language PLpgSQL;
