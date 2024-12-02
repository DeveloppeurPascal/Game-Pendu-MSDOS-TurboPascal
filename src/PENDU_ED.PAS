Program Pendu_Editeur;       { Mise … jour le 23/03/1991. }
{
Auteur: Patrick Pr‚martin.
Date: 16/03/1991.
      23/03/1991.
Langage: Turbo Pascal 4.0
      22/08/1991.
Langage: Turbo Pascal 6.0

But: Cr‚ation du fichier de donn‚es utilis‚ par le jeu PENDU.
}

Uses
    Crt,
    olf_software,
    U_Aff_Chaine,
    U_Code_Clavier,
    U_Curseur,
    U_Ger_Chaine,
    U_Sai_Donnee,
    U_Sgf,
    U_Util;

Const
     Nb_Max_Mots         = 2500;
     Nom_Fichier_Donnees = 'PENDU.DAT';
     Sentinelle_Maxi     = #$Ff;
     date_version : string [10] = '16/03/1991';
     num_version : string [3]  = '1.0';

Type String20    = String [20];
     T_Mots      = String20;
     T_Vect_Mots = Array [1..Nb_Max_Mots] Of T_Mots;

Var Vect_Mots : T_Vect_Mots;
    Nb_Mots   : Integer;

Procedure Presentation;
Begin { presentation }
  Curseur_Off;
  Clrscr;
  Affic_Center_Ln ('Editeur du fichier de donn‚es pour:');
  Affic_Center_Ln ('PENDU');
  Writeln;
  Writeln;
  Writeln;
  Writeln ('Veuillez patienter, je charge les donn‚es...')
End; { presentation }

Procedure Initialisation;
Var Le_Fichier : Text;
    I          : Integer;
Begin { initialisation }
  For I := 1 To Nb_Max_Mots Do
    Vect_Mots [I] := Sentinelle_Maxi
  {endfor};
  Nb_Mots := 0;
  If Exist (Nom_Fichier_Donnees)
  Then
    Begin
      Assign (Le_Fichier, Nom_Fichier_Donnees);
      Reset (Le_Fichier);
      While Not Eof (Le_Fichier) Do
        Begin
          Inc (Nb_Mots);
          Readln (Le_Fichier, Vect_Mots [Nb_Mots])
        End
      {endwhile};
      Close (Le_Fichier)
    End
  {endif};
  Attente_Appuit_Touche
End; { initialisation }

Procedure Affiche_Mot (X, Y : Integer; Mot : T_Mots; Inverse : Boolean);
Begin { affiche_mot }
  Gotoxy (X, Y);
  If Inverse
  Then
    Textattr := $70
  Else
    Textattr := $07
  {endif};
  Write (Mot);
  Textattr := $07
End; { affiche_mot }

Procedure Visualiser;
Var I, J,
    X, Y  : Integer;
    Carac : Char;
Begin { visualiser }
  Curseur_Off;
  If (Nb_Mots > 0)
  Then
    Begin
      I := 1;
      J := 0;
      Repeat
        X := 1;
        Y := 1;
        If (J <> I)
        Then
          Begin
            Clrscr;
            J := I;
            While Not ((J > Nb_Mots) Or (Y = 20)) Do
              Begin
                Affiche_Mot (X, Y, Vect_Mots [J], False);
                Inc (X, 20);
                If (X >= 80)
                Then
                  Begin
                    Inc (Y);
                    X := 1
                  End
                {endif};
                Inc (J)
              End
            {endwhile};
            J := I
          End
        {endif};
        Carac := Readkey;
        Case Carac Of
          Carac_Nul : Case Readkey Of
                        Touche_Haut : If (I > 80)
                                      Then
                                        I := I - 80
                                      {endif};
                        Touche_Bas  : If (I + 80 < Nb_Mots)
                                      Then
                                        I := I + 80
                                      {endif}
                      End
        End
      Until ((Carac = Touche_Escape) Or (Carac = ' '))
    End
  {endif}
End; { visualiser }

Procedure Dichotomie (Chaine : T_Mots; Var Position : Integer);
Var Debut,
    Fin,
    Milieu : Integer;
Begin { dichotomie }
  Debut := 1;
  Fin := Nb_Mots + 1;
  While Not (Debut = Fin) Do
    Begin
      Milieu := (Debut + Fin) Div 2;
      If (Vect_Mots [Milieu] < Chaine)
      Then
        Debut := Milieu + 1
      Else
        Fin := Milieu
      {endif}
    End
  {endwhile};
  Position := Debut
End; { dichotomie }

Procedure Inserer;
Var Position,
    I         : Integer;
    Chaine    : String;
Begin { inserer }
  Curseur_Pave;
  Clrscr;
  Repeat
    If (Nb_Mots + 1 < Nb_Max_Mots)
    Then
      Begin
        Write ('Ins‚rez le nouveau mot: ');
        Saisie_Texte ('AAAAAAAAAAAAAAAAAAAA', Chaine);
        Writeln;
        If (Chaine <> '')
        Then
          Begin
            Chaine := Set_Maj_Chaine (Chaine);
            Dichotomie (Chaine, Position);
            If (Vect_Mots [Position] = Chaine)
            Then
              Begin
                Message_Alerte ('Ce mot est d‚j… present...', True);
                Clrscr
              End
            Else
              Begin
                Inc (Nb_Mots);
                For I := Nb_Mots Downto Succ (Position) Do
                  Vect_Mots [I] := Vect_Mots [Pred (I)]
                {endfor};
                Vect_Mots [Position] := Chaine
              End
            {endif}
          End
        {endif}
      End
    Else
      Message_Alerte ('Plus de place en m‚moire...', True)
    {endif}
  Until ((Chaine = '') Or (Nb_Mots + 1 >= Nb_Max_Mots))
End; { inserer }

Function Minimum (A, B : Integer) : Integer;
Begin { minimum }
  If (A < B)
  Then
    Minimum := A
  Else
    Minimum := B
  {endif}
End; { minimum }

Procedure Effacer;
Var I, J, K,
    X, Y,
    Num_Mot : Integer;
    Carac   : Char;
Begin { effacer }
  Curseur_Off;
  If (Nb_Mots > 0)
  Then
    Begin
      I := 1;
      J := 0;
      Num_Mot := 1;
      K := 0;
      Repeat
        X := 1;
        Y := 4;
        If (J <> I)
        Then
          Begin
            Clrscr;
            J := I;
            While Not ((J > Nb_Mots) Or (Y = 24)) Do
              Begin
                Affiche_Mot (X, Y, Vect_Mots [J], (Num_Mot = (I + ((X-1) Div 20) Mod 4 + (Y-4) * 4)));
                Inc (X, 20);
                If (X >= 80)
                Then
                  Begin
                    Inc (Y);
                    X := 1
                  End
                {endif};
                Inc (J)
              End
            {endwhile};
            J := I;
            K := Num_Mot
          End
        {endif};
        If (K <> Num_Mot)
        Then
          Begin
            Affiche_Mot (20*((K-I) Mod 4)+1, (K-I) Div 4 +4, Vect_Mots [K], False);
            Affiche_Mot (20*((Num_Mot-I) Mod 4)+1, (Num_Mot-I) Div 4 +4, Vect_Mots [Num_Mot], True);
            K := Num_Mot
          End
        {endif};
        Carac := Readkey;
        Case Carac Of
          Carac_Nul : Case Readkey Of
                        Touche_Page_Up : If (I > 80)
                                         Then
                                           Begin
                                             I := I - 80;
                                             Num_Mot := Num_Mot - 80
                                           End
                                         {endif};
                        Touche_Page_Dn  : If (I + 80 <= Nb_Mots)
                                          Then
                                            Begin
                                              I := I + 80;
                                              Num_Mot := Minimum (Num_Mot + 80, Nb_Mots)
                                            End
                                          {endif};
                        Touche_Haut     : If (Num_Mot > I + 3)
                                          Then
                                            Num_Mot := Num_Mot - 4
                                          {endif};
                        Touche_Bas      : If (Num_Mot < Minimum (I + 76, Nb_Mots))
                                          Then
                                            Num_Mot := Num_Mot + 4
                                          {endif};
                        Touche_Gauche   : If (Num_Mot > I)
                                          Then
                                            Dec (Num_Mot)
                                          {endif};
                        Touche_Droite   : If (Num_Mot < Minimum (I + 79, Nb_Mots))
                                          Then
                                            Inc (Num_Mot)
                                          {endif}
                      End;
          Touche_Return : If Question_Alerte (Concat ('Voulez-vous effacer ', Vect_Mots [Num_Mot]))
                          Then
                            Begin
                              For I := Num_Mot To Nb_Mots Do
                                Vect_Mots [I] := Vect_Mots [Succ (I)]
                              {endfor};
                              Dec (Nb_Mots);
                              Carac := Touche_Escape
                            End
                          {endif}
        End
      Until ((Carac = Touche_Escape) Or (Carac = ' '))
    End
  {endif}
End; { effacer }

Procedure Sauver;
Var Le_Fichier : Text;
    I          : Integer;
Begin { sauver }
  Assign (Le_Fichier, Nom_Fichier_Donnees);
  Rewrite (Le_Fichier);
  For I := 1 To Nb_Mots Do
    Begin
      Writeln (Le_Fichier, Vect_Mots [I]);
      Case (I Mod 4) Of
        1 : Curseur_Haut;
        2 : Curseur_Milieu;
        3 : Curseur_Bas;
        4 : Curseur_Milieu
      End
    End
  {endfor};
  Close (Le_Fichier)
End; { sauver }

Procedure Traitement;
Var Sortie : Boolean;
    Carac  : Char;
Begin { traitement }
  Sortie := False;
  Repeat
    Clrscr;
    Writeln ('Editeur du fichier de donnees pour PENDU.');
    Writeln ('Copyright '+date_version+' Patrick Pr‚martin.');
    Writeln;
    Writeln ('Nombre de mots: ', Nb_Mots);
    Writeln;
    Writeln ('Choisissez une option: ');
    Writeln ('     1 - Visualiser les donn‚es.');
    Writeln ('     2 - Ins‚rer un mot.');
    Writeln ('     3 - Effacer un mot.');
    Writeln ('     4 - Sauver les modifications.');
    Writeln ('     5 - Quitter le programme.');
    Writeln;
    Write   ('          Votre choix ?');
    Curseur_Milieu;
    While Keypressed Do
      Carac := Readkey
    {endwhile};
    Carac := Readkey;
    Case Carac Of
      '1' : Visualiser;
      '2' : Inserer;
      '3' : Effacer;
      '4' : Sauver;
      '5' : Sortie := Question_Alerte ('Voulez-vous quitter ce programme ?')
    End
  Until Sortie
End; { traitement }

Begin
     init_licence ('GAMEPEND');
     init_olf_message (mess_shareware);
     init_olf_software ('Pendu Editeur '+num_version, #155' PREPAT '+date_version);
     Curseur_Off;
     Presentation;
     Initialisation;
     Traitement;
     Curseur_On
End.
