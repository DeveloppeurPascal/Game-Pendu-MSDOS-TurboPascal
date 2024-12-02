Program Pendu;               { Mise … jour le 23/03/1991. }
{
Auteur: Patrick Pr‚martin.
Date: 17/03/1991.
      23/03/1991.
Langage: Turbo Pascal 4.0
      22/08/1991.
Langage: Turbo Pascal 6.0

But: Jeu du pendu.
Regle: Decouvrir un mot en donnant des lettres, on a droit … un certain nombre
       d'erreurs, mais pas beaucoup.
}

Uses
    Crt,

    olf_software,

    U_Aff_Chaine,
    U_Code_Clavier,
    U_Curseur,
    U_Fenetre,
    U_Ger_Chaine,
    U_Sai_Donnee,
    U_Score,
    U_Sgf,
    U_Util;

Const
     Nb_Max_Mots         = 2500;
     Nom_Fichier_Donnees = 'PENDU.DAT';
     Sentinelle_Maxi     = #$Ff;
     num_version : string [3] = '1.0';
     date_version : string [10] = '17/03/1991';

Type String20       = String [20];
     T_Mots         = String20;
     T_Vect_Mots    = Array [1..Nb_Max_Mots] Of T_Mots;
     T_Vect_Present = Array [1..Nb_Max_Mots] Of Boolean;

Var Vect_Mots        : T_Vect_Mots;
    Vect_Present     : T_Vect_Present;
    Increment,
    Maxi_Score,
    Nb_Choisis,
    Nb_Mots_Choisis,
    Nb_Mots          : Integer;
    Ok               : Boolean;

Procedure Initialisation;
Var Le_Fichier : Text;
Begin { initialisation }
  Init_Score ('PENDU');
  For Nb_Mots := 1 To Nb_Max_Mots Do
    Begin
      Vect_Mots [Nb_Mots]    := Sentinelle_Maxi;
      Vect_Present [Nb_Mots] := False
    End
  {endfor};
  Nb_Mots := 0;
  If Exist (Nom_Fichier_Donnees)
  Then
    Begin
      Assign (Le_Fichier, Nom_Fichier_Donnees);
      Reset (Le_Fichier);
      While Not (Eof (Le_Fichier)) Do
        Begin
          Inc (Nb_Mots);
          Vect_Present [Nb_Mots] := True;
          Readln (Le_Fichier, Vect_Mots [Nb_Mots])
        End
      {endwhile};
      Close (Le_Fichier)
    End
  {endif};
  Randomize;
  Nb_Mots_Choisis := 0;
  Ok := (Nb_Mots > 0)
End; { initialisation }

Function Int_Str (Nombre : Integer): String;
Var Chaine : String;
Begin { int_str }
  Str (Nombre, Chaine);
  Int_Str := Chaine
End; { int_str }

Procedure Presentation;
Begin { presentation }
  Clear_Window;
  Type_Cadre := 7;
  Window_Fond_Cadre_Bis (2, 2, 79, 23, Red, Yellow, Blue);
  Window_Titre ('PENDU', White, Blue);
  Affic_Center_Ln ('Auteur: Patrick Pr‚martin.');
  Affic_Center_Ln ('Date: '+date_version);
  Writeln;
  Affic_Center_Ln ('Voici le celebre jeu du pendu fait en Turbo Pascal 4.0');
  Writeln;
  Affic_Center_Ln ('Je pense qu''il est inutile d''en rappeler les rŠgles...');
  Affic_Center_Ln ('Mais les voici quand mˆme.');
  Writeln;
  Affic_Center_Ln (Concat ('L''ordinateur va choisir un mot parmi les ', Int_Str (Nb_Mots), ' mots qu''il a'));
  Affic_Center_Ln ('en memoire, puis il va vous demander d''en retrouver les lettres.');
  Affic_Center_Ln ('Vous avez droit … 8 erreurs, si ce chiffre est d‚pass‚ avant que vous ne');
  Affic_Center_Ln ('trouviez ce mot, vous aurez perdu, sinon, l''ordinateur en choisira un autre.');
  Writeln;
  Affic_Center_Ln ('Il est possible de sauver les scores si vous le d‚sirez, mais faites');
  Affic_Center_Ln ('attention aux virus qui se promŠnent un peu partout...');
  Affic_Center_Ln ('Et je l''espŠre pas ici !');
  Writeln;
  Affic_Center_Ln ('Bonne chance...');
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { presentation }

Procedure Dessin_Pendu (Num : Integer);
Var I : Integer;
Begin { dessin_pendu }
  Window (2, 2, 11, 11);
  Textcolor (Lightgray);
  Textbackground (Brown);
  Case Num Of
    1 : For I := 2 To 9 Do
          Begin
            Gotoxy (I, 9);
            Write (#219)     { #219 = Û }
          End
        {endfor};
    2 : For I := 8 Downto 3 Do
          Begin
            Gotoxy (7, I);
            Write (#219)     { #219 = Û }
          End
        {enfor};
    3 : For I := 9 Downto 4 Do
          Begin
            Gotoxy (I, 2);
            Write (#219)     { #219 = Û }
          End
        {endfor};
    4 : Begin
          Gotoxy (4, 3);
          Write (#124)       { #124 = | }
        End;
    5 : Begin
          Gotoxy (4, 4);
          Write ('O')
        End;
    6 : Begin
          Gotoxy (4, 5);
          Write (#219)       { #219 = Û }
        End;
    7 : Begin
          Gotoxy (3, 5);
          Write ('/');
          Gotoxy (5, 5);
          Write ('\')
        End;
    8 : Begin
          Gotoxy (3, 6);
          Write ('/');
          Gotoxy (5, 6);
          Write ('\')
        End
  End
End; { dessin_pendu }

Function Choix_Mot : T_Mots;
Var I : Integer;
Begin { choix_mot }
  If (Nb_Mots_Choisis = Nb_Mots)
  Then
    Begin
      Nb_Mots_Choisis := 0;
      For I := 1 To Nb_Mots Do
        Vect_Present [I] := True
      {endfor}
    End
  {endif};
  Inc (Nb_Mots_Choisis);
  Inc (Nb_Choisis);
  I := Trunc (Random (Nb_Mots));
  If Not (Vect_Present [I])
  Then
    While Not (Vect_Present [I]) Do
      Begin
        Inc (I);
        If (I > Nb_Mots)
        Then
          I := 1
        {endif}
      End
    {endwhile}
  {endif};
  Vect_Present [I] := False;
  Choix_Mot := Vect_Mots [I]
End; { choix_mot }

Procedure Affic_Lettres (Lettres : String);
Begin { affic_lettres }
  Window (2, 14, 79, 14);
  Textcolor (White);
  Textbackground (Blue);
  Clrscr;
  Affic_Center (Lettres)
End; { affic_lettres }

Procedure Affic_Mot (Mot : T_Mots);
Begin { affic_mot }
  Window (14, 5, 50, 5);
  Textcolor (Black);
  Textbackground (Lightgray);
  Clrscr;
  Affic_Center (Mot)
End; { affic_mot }

Procedure Choix_Lettre (Mot_Cou : T_Mots; Var Carac : Char);
Var I : Integer;
Begin { choix_lettre }
  Window (50, 20, 79, 20);
  Curseur_Pave;
  Repeat
    Clrscr;
    While Keypressed Do
      Begin
        I := Trunc (Random (Nb_Mots));
        Carac := Readkey
      End
    {endwhile};
    While Not Keypressed Do
      I := Trunc (Random (Nb_Mots))
    {endwhile};
    Carac := Upcase (Readkey);
    If (Carac = Touche_Ctrl_C)
    Then
      Begin
        Affic_Center (Mot_Cou);
        I := 1;
        While Not ((Keypressed) Or (I > 5)) Do
          Begin
            Inc (I);
            Delay (1)
          End
        {endhwile}
      End
    {endif};
    Affic_Center (Carac)
  Until (Carac In ['A'..'Z'])
End; { choix_lettre }

Function Traitement (Mot_Cou : T_Mots) : Boolean;
Var Carac     : Char;
    I,
    Nb_Fautes : Integer;
    Lettres,
    Mot_Aff   : String;
Begin { traitement }
  Nb_Fautes := 0;
  Lettres := '';
  Mot_Aff := '';
  For I := 1 To Length (Mot_Cou) Do
    Insert ('-', Mot_Aff, 1)
  {endfor};
  Repeat
    Affic_Lettres (Lettres);
    Affic_Mot (Mot_Aff);
    Choix_Lettre (Mot_Cou, Carac);
    If ((Pos (Carac, Mot_Cou) = 0) And (Pos (Carac, Lettres) = 0))
    Then
      Begin
        Inc (Nb_Fautes);
        Dessin_Pendu (Nb_Fautes)
      End
    Else
      If (Pos (Carac, Lettres) = 0)
      Then
        For I := 1 To Length (Mot_Cou) Do
          If (Carac = Mot_Cou [I])
          Then
            Mot_Aff [I] := Carac
          {endif}
        {endfor}
      {endif}
    {endif};
    If (Pos (Carac, Lettres) = 0)
    Then
      Begin
        I := 1;
        While Not ((I > 2*Length (Lettres)) Or (Lettres [I] > Carac)) Do
          Inc (I, 2)
        {endwhile};
        Insert (Carac+' ', Lettres, I)
      End
    {endif}
  Until ((Mot_Cou = Mot_Aff) Or (Nb_Fautes > 7));
  Affic_Lettres (Lettres);
  Affic_Mot (Mot_Aff);
  Increment := (9 - Nb_Fautes) * 100 Div 8;
  Maxi_Score := Nb_Choisis * (900 Div 8);
  Traitement := (Mot_Cou = Mot_Aff)
End; { traitement }

Procedure Gagne (Var Score : Integer;
                 Mot       : T_Mots);
Begin { gagne }
  Score := Score + Increment;
  Message_Alerte (Concat ('Vous avez trouve le mot: ', Mot), True);
  Message_Alerte (Concat ('Votre score est maintenant de: ', Int_Str (Score), ' sur ',
                  Int_Str (Maxi_Score)), True)
End; { gagne }

Procedure Perdu (Score : Integer;
                 Mot   : T_Mots);
Begin { perdu }
  Message_Alerte ('Vous avez perdu...', True);
  Message_Alerte (Concat ('Le mot … trouver ‚tait: ', Mot), True);
  Message_Alerte (Concat ('Votre score final est de: ', Int_Str (Score), ' sur ',
                  Int_Str (Maxi_Score)), True);
  Reset_Screen;
  Clrscr;
  Nouveau_Score (Score, Maxi_Score);
  Clrscr;
  Affichage_Score;
  Attente_Appuit_Touche;
  Clrscr;
  If Question_Alerte ('Voulez-vous sauver les scores ?')
  Then
    Sauve_Score ('PENDU')
  {endif}
End; { perdu }

Procedure Jeu;
Var Score  : Integer;
    Sortie : Boolean;
    Mot    : T_Mots;
Begin { jeu }
  Score := 0;
  Nb_Choisis := 0;
  Repeat
    Reset_Screen;
{ Cadre pour le dessin du pendu. }
    Type_Cadre := 6;
    Window_Fond_Cadre_Bis (2, 2, 11, 11, Brown, Black, Red);
    Window_Titre ('Vous:', White, Red);
{ Cadre contenant les lettres d‚j… tap‚es. }
    Window_Fond_Cadre_Bis (2, 14, 79, 14, Blue, Lightgray, Brown);
    Window_Titre ('Lettres utilis‚es.', Black, Brown);
{ Cadre contenant le mot choisi par l'ordinateur. }
    Window_Fond_Cadre_Bis (14, 5, 50, 5, Lightgray, Blue, Black);
    Window_Titre ('Le mot courant:', White, Black);
{ Cadre du choix d'une lettre. }
    Window_Fond_Cadre_Bis (50, 20, 79, 20, Blue, Black, Lightgray);
    Window_Titre ('Quelle lettre voulez-vous ?', White, Black);
{ D‚roulement du jeu. }
    Mot := Choix_Mot;
    Sortie := Not (Traitement (Mot));
    If Not (Sortie)
    Then
      Gagne (Score, Mot)
    {endif}
  Until Sortie;
  Perdu (Score, Mot)
End; { jeu }

Begin
     init_licence ('GAMEPEND');
     init_olf_message (mess_shareware);
     init_olf_software ('Pendu '+num_version, #155' PREPAT '+date_version);
     Curseur_Off;
     Reset_Screen;
     Initialisation;
     If Not Ok
     Then
         Message_Alerte ('Le fichier de donn‚es PENDU.DAT est introuvable...', True)
     Else
         Begin
              Presentation;
              Repeat
                    Jeu
              Until Not (Question_Alerte ('Voulez-vous essayer … nouveau ?'))
         End;
     {endif}
     Reset_Screen;
     Curseur_On
End.
