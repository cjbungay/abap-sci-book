class Z_CL_CI_SCAN_INCONSO_2010_BL definition
  public
  inheriting from CL_CI_TEST_SCAN
  create public .

public section.
*"* public components of class Z_CL_CI_SCAN_INCONSO_2010_BL
*"* do not include other source files here!!!

  methods CONSTRUCTOR .

  methods GET_ATTRIBUTES
    redefinition .
  methods IF_CI_TEST~QUERY_ATTRIBUTES
    redefinition .
  methods PUT_ATTRIBUTES
    redefinition .
  methods RUN
    redefinition .
protected section.
*"* protected components of class Z_CL_CI_SCAN_INCONSO_2010_BL
*"* do not include other source files here!!!

  data AH_SEL_DOC_BLANKLINE_LEVEL type INT1 value 25. "#EC NOTEXT .
  data AH_SEL_DOC_BLANKLINE_LEVL_PRIO type Z_SCI_MSG_LEVEL_DSP .
  data AH_SEL_DOC_COMMENT_LEVEL type INT1 value 25. "#EC NOTEXT .
  data AH_SEL_DOC_COMMENT_LEVEL_PRIO type Z_SCI_MSG_LEVEL_DSP .
  data AH_SEL_DOC_HEADER_INFO_CHANGED type FLAG value 'X'. "#EC NOTEXT .
  data AH_SEL_DOC_HEADER_INFO_CREATED type FLAG value 'X'. "#EC NOTEXT .
  data AH_SEL_DOC_HEADER_POSITION type FLAG value 'X'. "#EC NOTEXT .
  data AH_SEL_DOC_HEADER_STRUCTURE type FLAG value 'X'. "#EC NOTEXT .
private section.
*"* private components of class Z_CL_CI_SCAN_INCONSO_2010_BL
*"* do not include other source files here!!!

  data AH_DOC_HEADER_ID type STRING .
  data AT_DOC_HEADER_INFO_CHANGED type STRING_TABLE .
  data AT_DOC_HEADER_INFO_CREATED type STRING_TABLE .
  data AT_DOC_HEADER_POSITION type INT4_TABLE .
  data AT_DOC_HEADER_STRUCTURE type STRING_TABLE .
  constants C_MY_NAME type SEOCLSNAME value 'Z_CL_CI_SCAN_INCONSO_2010_BL'. "#EC NOTEXT
  constants C_TEST_CODE_BLANKLINE_PROZ type SCI_ERRC value '1101'. "#EC NOTEXT
  constants C_TEST_CODE_COMMENT_PROZ type SCI_ERRC value '1102'. "#EC NOTEXT
  constants C_TEST_CODE_HDR_MULTI_HEADER type SCI_ERRC value '1002'. "#EC NOTEXT
  constants C_TEST_CODE_HDR_NO_HEADER type SCI_ERRC value '1001'. "#EC NOTEXT
  constants C_TEST_CODE_HDR_NO_POSITION type SCI_ERRC value '1003'. "#EC NOTEXT
  constants C_TEST_CODE_HDR_WRONG_STRUCT type SCI_ERRC value '1004'. "#EC NOTEXT
  constants C_TEST_CODE_NO_LEVEL_INFO type SCI_ERRC value '0103'. "#EC NOTEXT
  constants C_TEST_CODE_NO_LEVEL_NAME type SCI_ERRC value '0104'. "#EC NOTEXT
  constants C_TEST_CODE_NO_SCAN type SCI_ERRC value '0101'. "#EC NOTEXT
  constants C_TEST_CODE_NO_SOURCE type SCI_ERRC value '0105'. "#EC NOTEXT
  constants C_TEST_CODE_SCAN_ERROR type SCI_ERRC value '0102'. "#EC NOTEXT

  methods CHECK_DOC_COMMENT
    importing
      !PIF_LEVEL type SLEVEL .
  methods CHECK_DOC_HEADER
    importing
      !PIF_LEVEL type SLEVEL .
  methods FILL_ATTRIBUTES
    exporting
      !PET_ATTRIBUTE type SCI_ATTTAB .
  methods FILL_HEADER_STRUCTURE .
  methods FILL_MESSAGES .
ENDCLASS.



CLASS Z_CL_CI_SCAN_INCONSO_2010_BL IMPLEMENTATION.


METHOD check_doc_comment.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-22  rschilcher   Reinhard Schilcher                        *
*             Prüfungen bezüglich Kommentare und Leerzeilen.         *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Check_Doc_Comment                                     ***
*** -> Diverse Prüfungen bezüglich der Kommentierung des Codes.    ***
**********************************************************************
*** => Eine Leerzeile ist eine komplett leere Zeile. Eine          ***
***    Kommentarzeile beginnt mit einem "*" und enthält mindestens ***
***    vier Zeichen, die nicht identisch sind.                     ***
**********************************************************************

  DATA:

* Source Code
        lt_source                     TYPE string_table,

* Allgemeines
        h_number_of_blanklines        TYPE i,
        h_number_of_comments          TYPE i,
        h_number_of_lines             TYPE i,
        h_percent                     TYPE i,

* Exception
        h_param1                      TYPE string,
        h_param2                      TYPE string,
        h_param3                      TYPE string,
        h_param4                      TYPE string.

  FIELD-SYMBOLS:

* Source Code
        <fs_source>                   TYPE string.


**********************************************************************
*** Allgemeines                                                    ***
**********************************************************************

* Initialisierung
  CLEAR lt_source.

  CLEAR h_number_of_blanklines.
  CLEAR h_number_of_comments.
  CLEAR h_number_of_lines.


**********************************************************************
*** Benutzerauswahl für Kommentar-Prüfungen prüfen                 ***
**********************************************************************

* Es sind keine Kommentar-Überprüfungen gewünscht ...
  IF ( ah_sel_doc_blankline_levl_prio IS INITIAL )
    AND ( ah_sel_doc_comment_level_prio IS INITIAL ).

* Es gibt nichts zu tun -> Abbruch!
    RETURN.
  ENDIF.

* Leerzeilen-Schwelle anpassen
  IF ( ah_sel_doc_blankline_level < 1 )
    OR ( ah_sel_doc_blankline_level > 99 ).

* Leerzeilen-Schwelle auf Defaultwert setzen
    ah_sel_doc_blankline_level = 30.
  ENDIF.

* Kommentar-Schwelle anpassen
  IF ( ah_sel_doc_comment_level < 1 )
    OR ( ah_sel_doc_comment_level > 99 ).

* Kommentar-Schwelle auf Defaultwert setzen
    ah_sel_doc_comment_level = 30.
  ENDIF.


**********************************************************************
*** Übergabeparameter prüfen                                       ***
**********************************************************************

* Level prüfen
  IF ( pif_level IS INITIAL ).

* Fehlermeldung (Kommentarprüfung nicht möglich)
    CALL METHOD inform
      EXPORTING
        p_test    = c_my_name
        p_code    = c_test_code_no_level_info
        p_param_1 = c_my_name
        p_param_2 = 'CHECK_DOC_COMMENT'.

* Es ist nichts zum Prüfen da -> Abbruch!
    RETURN.
  ENDIF.

* Level-Name prüfen
  IF ( pif_level-name IS INITIAL ).

* Fehlermeldung (Kommentarprüfung nicht möglich)
    CALL METHOD inform
      EXPORTING
        p_test    = c_my_name
        p_code    = c_test_code_no_level_name
        p_param_1 = c_my_name
        p_param_2 = 'CHECK_DOC_COMMENT'.

* Es ist nichts zum Prüfen da -> Abbruch!
    RETURN.
  ENDIF.

* Level-Type prüfen (es werden nur Programmtypen verarbeitet (= 'P'))
  IF ( pif_level-type <> scan_level_type-program ).

* Typ ist was anderes z.B. Macro -> Abbruch!
    RETURN.
  ENDIF.


**********************************************************************
*** Source Code ermitteln                                          ***
**********************************************************************

* Source Code laden
  READ REPORT pif_level-name INTO lt_source.

* Kein Source Code vorhanden ...
  IF ( lt_source IS INITIAL )
    OR ( lines( lt_source ) < 1 ).

* Fehlermeldung (Kommentarprüfung nicht möglich)
    CALL METHOD inform
      EXPORTING
        p_sub_obj_type = c_type_include
        p_sub_obj_name = pif_level-name
        p_line         = 1
        p_column       = 1
        p_test         = c_my_name
        p_code         = c_test_code_no_source
        p_param_1      = c_my_name
        p_param_2      = 'CHECK_DOC_COMMENT'.

* Es ist nichts zum Prüfen da -> Abbruch!
    RETURN.
  ENDIF.


**********************************************************************
*** Code analysieren                                               ***
**********************************************************************

* Alle Code-Zeilen abklappern
  LOOP AT lt_source ASSIGNING <fs_source>.

* Zeile ist komplett leer ...
    IF ( <fs_source> IS INITIAL ).

* Leerzeile merken
      h_number_of_blanklines = h_number_of_blanklines + 1.

* Erstes Zeichen ist ein "*", also ein Kommentar ...
    ELSEIF ( <fs_source>(1) = '*' ).

* Mindestens 4 Zeichen in der Zeile (Keine Leerzeichen)
      FIND REGEX '\S{4}' IN <fs_source>.

* Gültigen Kommentar gefunden ...
      IF ( sy-subrc = 0 ).

* Handelt es sich um einen sinnvollen Kommentar oder um Wiederholungszeichen?
* -> Da SAP bei ABAP kein Lookbehind in ihrem REGEX umgesetzt hat,
*    wird hier ein erneutes Auswerten nötig!
        FIND REGEX '[\*\-\.\<\>\&#]{4}' IN <fs_source>.

* Gültigen Kommentar gefunden ...
        IF ( sy-subrc <> 0 ).

* Kommentar merken
          h_number_of_comments = h_number_of_comments + 1.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Gesamtzahl an Zeilen ermitteln
  h_number_of_lines = lines( lt_source ).


**********************************************************************
*** Leerzeilen auswerten                                           ***
**********************************************************************

* Leerzeilen sollen ausgewertet werden ...
  IF ( ah_sel_doc_blankline_levl_prio IS NOT INITIAL ).

* Prozentzahl an Leerzeilen berechnen
    h_percent = ( h_number_of_blanklines * 100 ) / h_number_of_lines.

* Zahl der Leerzeilen liegt unterhalb der eingestellten Schwelle ...
    IF ( h_percent < ah_sel_doc_blankline_level ).

* Daten konvertieren
      MOVE h_percent TO h_param3.
      MOVE ah_sel_doc_blankline_level TO h_param4.

* Zum Prüf-Ergebnis hinzufügen
      CALL METHOD inform
        EXPORTING
          p_sub_obj_type = c_type_include
          p_sub_obj_name = pif_level-name
          p_line         = 1
          p_column       = 1
          p_test         = c_my_name
          p_code         = c_test_code_blankline_proz
          p_param_1      = c_my_name
          p_param_2      = 'CHECK_DOC_COMMENT'
          p_param_3      = h_param3
          p_param_4      = h_param4.
    ENDIF.
  ENDIF.


**********************************************************************
*** Kommentare auswerten                                           ***
**********************************************************************

* Kommentare sollen ausgewertet werden ...
  IF  ( ah_sel_doc_comment_level_prio IS NOT INITIAL ).

* Prozentzahl an Kommentarzeilen berechnen
    h_percent = ( h_number_of_comments * 100 ) / h_number_of_lines.

* Anzahl an Kommentarzeilen liegt unterhalb der eingestellten Schwelle ...
    IF ( h_percent < ah_sel_doc_comment_level ).

* Daten konvertieren
      MOVE h_percent TO h_param3.
      MOVE ah_sel_doc_comment_level TO h_param4.

* Zum Prüf-Ergebnis hinzufügen
      CALL METHOD inform
        EXPORTING
          p_sub_obj_type = c_type_include
          p_sub_obj_name = pif_level-name
          p_position     = 1
          p_line         = 1
          p_column       = 1
          p_test         = c_my_name
          p_code         = c_test_code_comment_proz
          p_param_1      = c_my_name
          p_param_2      = 'CHECK_DOC_COMMENT'
          p_param_3      = h_param3
          p_param_4      = h_param4.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD check_doc_header.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-17  rschilcher   Reinhard Schilcher                        *
*             Prüfungen bezüglich des Headers.                       *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Check_Doc_Header                                      ***
*** -> Diverse Prüfungen bezüglich der Verwendung des Headers.     ***
**********************************************************************
*** => Eine Überprüfung der Erstellungs- und Änderungstruktur ist  ***
***    in dieser Prüfung nicht vorhanden! Die Einstellmöglichkeit  ***
***    dieser beiden Punkte dienen nur dazu, in der Demo das       ***
***    Aussehen von Checkboxen im Parameterauswahlbildschirms zu   ***
***    zeigen.                                                     ***
**********************************************************************

  DATA:

* Source Code
        lt_source                     TYPE string_table,

* Header
        h_header_id_pos               TYPE i,

        h_header_start_pos            TYPE i,

* Allgemeines
        h_line_nr                     TYPE i,

        h_ok                          TYPE flag,

* Exception
        h_param1                      TYPE string,
        h_param2                      TYPE string,
        h_param3                      TYPE string,
        h_param4                      TYPE string.

  FIELD-SYMBOLS:

* Source Code
        <fs_source>                   TYPE string,

* Header
        <fs_position>                 TYPE int4,
        <fs_structure>                TYPE string.


**********************************************************************
*** Allgemeines                                                    ***
**********************************************************************

* Initialisierung
  CLEAR lt_source.

  CLEAR h_header_id_pos.
  CLEAR h_header_start_pos.


**********************************************************************
*** Benutzerauswahl für Header-Prüfungen prüfen                    ***
**********************************************************************

* Es sind keine Header-Überprüfungen gewünscht ...
  IF ( ah_sel_doc_header_position IS INITIAL )
    AND ( ah_sel_doc_header_structure IS INITIAL )
    AND ( ah_sel_doc_header_info_created IS INITIAL )
    AND ( ah_sel_doc_header_info_changed IS INITIAL ).

* Es gibt nichts zu tun -> Abbruch!
    RETURN.
  ENDIF.


**********************************************************************
*** Übergabeparameter prüfen                                       ***
**********************************************************************

* Level prüfen
  IF ( pif_level IS INITIAL ).

* Fehlermeldung (Prüfung nicht möglich)
    CALL METHOD inform
      EXPORTING
        p_test    = c_my_name
        p_code    = c_test_code_no_level_info
        p_param_1 = c_my_name
        p_param_2 = 'CHECK_DOC_HEADER'.

* Es ist nichts zum Prüfen da -> Abbruch!
    RETURN.
  ENDIF.

* Level-Name prüfen
  IF ( pif_level-name IS INITIAL ).

* Fehlermeldung (Prüfung nicht möglich)
    CALL METHOD inform
      EXPORTING
        p_test    = c_my_name
        p_code    = c_test_code_no_level_name
        p_param_1 = c_my_name
        p_param_2 = 'CHECK_DOC_HEADER'.

* Es ist nichts zum Prüfen da -> Abbruch!
    RETURN.
  ENDIF.

* Level-Type prüfen (es werden nur Programmtypen verarbeitet (= 'P'))
  IF ( pif_level-type <> scan_level_type-program ).

* Typ ist was anderes z.B. Macro -> Abbruch!
    RETURN.
  ENDIF.


**********************************************************************
*** Source Code ermitteln                                          ***
**********************************************************************

* Source Code laden
  READ REPORT pif_level-name INTO lt_source.

* Kein Source Code vorhanden ...
  IF ( lt_source IS INITIAL )
    OR ( lines( lt_source ) < 1 ).

* Fehlermeldung (Prüfung nicht möglich)
    CALL METHOD inform
      EXPORTING
        p_sub_obj_type = c_type_include
        p_sub_obj_name = pif_level-name
        p_line         = 1
        p_column       = 1
        p_test         = c_my_name
        p_code         = c_test_code_no_source
        p_param_1      = c_my_name
        p_param_2      = 'CHECK_DOC_HEADER'.

* Es ist nichts zum Prüfen da -> Abbruch!
    RETURN.
  ENDIF.


**********************************************************************
*** Code analysieren                                               ***
**********************************************************************

* Alle Code-Zeilen abklappern
  LOOP AT lt_source ASSIGNING <fs_source>.

* Diese Zeile enthält die Header-Kennung ...
    IF ( <fs_source> CS ah_doc_header_id ).

* Es ist der erste Header ...
      IF ( h_header_id_pos IS INITIAL ).

* Die Zeile der Header-Kennung merken
        h_header_id_pos = sy-tabix.

* Es gab schon eine Header-Kennung ...
      ELSE.

* Als mehrfach vorhanden markieren
        h_header_id_pos = - h_header_id_pos.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Keine Header-Kennungen vorhanden ...
  IF ( h_header_id_pos = 0 ).

* Fehlermeldung
    CALL METHOD inform
      EXPORTING
        p_sub_obj_type = c_type_include
        p_sub_obj_name = pif_level-name
        p_line         = 1
        p_column       = 1
        p_test         = c_my_name
        p_code         = c_test_code_hdr_no_header
        p_param_1      = c_my_name
        p_param_2      = 'CHECK_DOC_HEADER'.

* Kein Header vorhanden -> Abbruch!
    RETURN.
  ENDIF.

* Mehrfache Header-Kennungen vorhanden ...
  IF ( h_header_id_pos < 0 ).

* Fehlermeldung
    CALL METHOD inform
      EXPORTING
        p_sub_obj_type = c_type_include
        p_sub_obj_name = pif_level-name
        p_line         = h_header_id_pos
        p_column       = 1
        p_test         = c_my_name
        p_code         = c_test_code_hdr_multi_header
        p_param_1      = c_my_name
        p_param_2      = 'CHECK_DOC_HEADER'.

* Eintrag wieder korrekt setzen
    h_header_id_pos = - h_header_id_pos.
  ENDIF.

* Header-Startposition liegt nicht in der ersten Zeile ...
  IF ( h_header_id_pos > 1 ).

* Startposition ist eine Zeile höher!
    h_header_id_pos = h_header_id_pos - 1.
  ENDIF.


**********************************************************************
*** Startposition des Headers prüfen                               ***
*** -> Kennung ist eine Zeile unterhalb der Startposition.         ***
**********************************************************************

* Initialisierung
  CLEAR h_ok.

* Es ist eine Header-Positions-Überprüfungen gewünscht ...
  IF ( ah_sel_doc_header_position IS NOT INITIAL ).

* Alle Startpositionen des Headers abklappern
    LOOP AT at_doc_header_position ASSIGNING <fs_position>.

* Diese Startposition des Headers passt
      IF ( h_header_id_pos = <fs_position> ).

* Fund merken
        h_ok = 'X'.

* Schleife abbrechen!
        EXIT.
      ENDIF.

    ENDLOOP.

* Header an keiner der vorgegebenen Positionen gefunden
    IF ( h_ok IS INITIAL ).

* Daten konvertieren
      MOVE h_header_id_pos TO h_param3.

* Fehlermeldung
      CALL METHOD inform
        EXPORTING
          p_sub_obj_type = c_type_include
          p_sub_obj_name = pif_level-name
          p_line         = h_header_id_pos
          p_column       = 1
          p_test         = c_my_name
          p_code         = c_test_code_hdr_no_position
          p_param_1      = c_my_name
          p_param_2      = 'CHECK_DOC_HEADER'
          p_param_3      = h_param3.
    ENDIF.
  ENDIF.


**********************************************************************
*** Struktur des Headers prüfen                                    ***
**********************************************************************

* Initialisierung
  h_ok = 'X'.

* Es ist eine Header-Struktur-Überprüfungen gewünscht ...
  IF ( ah_sel_doc_header_structure IS NOT INITIAL ).

* Die Header-Struktur ablaufen
    LOOP AT at_doc_header_structure ASSIGNING <fs_structure>.

* Position der Zeile des Headers in Source Code Tabelle berechnen
      h_line_nr = h_header_id_pos + sy-tabix - 1.

      READ TABLE lt_source ASSIGNING <fs_source> INDEX h_line_nr.

* Die Zeilen stimmen nicht 100% überein ...
      IF ( <fs_structure> <> <fs_source> ).

* Als fehlerhaft markieren
        CLEAR h_ok.

* Schleife abbrechen!
        EXIT.
      ENDIF.

    ENDLOOP.

  ENDIF.

* Header-Strukur ist nicht korrekt ...
  IF ( h_ok IS INITIAL ).

* Fehlermeldung
    CALL METHOD inform
      EXPORTING
        p_sub_obj_type = c_type_include
        p_sub_obj_name = pif_level-name
        p_line         = h_header_id_pos
        p_column       = 1
        p_test         = c_my_name
        p_code         = c_test_code_hdr_wrong_struct
        p_param_1      = c_my_name
        p_param_2      = 'CHECK_DOC_HEADER'.
  ENDIF.

ENDMETHOD.


METHOD constructor.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-08  rschilcher   Reinhard Schilcher                        *
*             Prüfung für inconso AG Programmierrichtlinien 2010.    *
**********************************************************************




**********************************************************************
*** Methode: Constructor                                           ***
*** -> Initiales Anlegen eines Baum-Eintrages mit Funktionalität.  ***
**********************************************************************

* Übergeordnete Methode aufrufen
  super->constructor( ).

* Namen des Eintrags im Auswahlbaum
  description = 'inconso AG Prüfungen durchführen'(000).

* Kategorie (Klassenname) des übergeordneten Eintrags
  category = 'Z_CL_CI_CATEGORY_INCONSO_BL'.

* Position in der Kategorie des Auswahlbaumes
  position    = '001'.

* Attribute sind vorhanden (Symbol für Auswahlbox anzeigen)
  has_attributes = c_true.

* Attributsauswahl ist ok (Symbol für Auswahlbox ist grün)
  attributes_ok = c_true.

* Ergebnistexte füllen
  CALL METHOD fill_messages.

ENDMETHOD.


METHOD fill_attributes.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-17  rschilcher   Reinhard Schilcher                        *
*             Attribute für GUI-Anzeige füllen.                      *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Fill_Attributes                                       ***
*** -> Attribute für die Benutzerauswahl und Programmsteuerung     ***
***    anlegen und füllen.                                         ***
**********************************************************************
*** => Bei Parametern maximale Textlänge: 30 Zeichen               ***
***    Bei SelectOptions maximale Textlänge: 40 Zeichen            ***
**********************************************************************
*** => Hinzufügungen und Löschungen von Attributen müssen in       ***
***    "PUT_ATTRIBUTES" und "GET_ATTRIBUTES" nachgezogen werden,   ***
***    damit sie in der Prüfung auch ausgewertet werden können.    ***
**********************************************************************

  DATA:

* Attribut
        lf_attribute                  TYPE sci_attent.


**********************************************************************
*** Allgemeines                                                    ***
**********************************************************************

* Initialisierung
  CLEAR pet_attribute.


**********************************************************************
*** Macro zum Füllen eines Attributes                              ***
**********************************************************************

* Macro zum Füllen eines Attributes
  DEFINE fill_attr.

* Initialisierung
    clear lf_attribute.

* Referenz auf das Klassenattribut
* -> Handle auf das Ausgabefeld bzw. Ausgabetabelle (z.B. SelectOptions)
    get reference of &1 into lf_attribute-ref.

* Bezeichnung für das Eingabeelement (= Label)
    lf_attribute-text = &2.

* Ausgabeart des Attributes
* -> C = Checkbox, R = Radiobutton, S = SelectOptions, ...
    lf_attribute-kind = &3.

* Obligatorische Eingabe (= Mussfeld)
* -> Nicht leer => Obligatory
    if ( &4 is not initial ).
      lf_attribute-obligatory = 'X'.
    endif.

* Gruppenbezeichnung für Radiobuttons
    if ( &5 is not initial ).
      lf_attribute-button_group = &5.
    endif.

* Dieses Attribut zur Attributliste hinzufügen
    append lf_attribute to pet_attribute.

  END-OF-DEFINITION.


**********************************************************************
*** Attribute für die GUI-Ausgabe füllen (für Benutzerauswahl)     ***
*** -> Macroname | Instanzattribut | Beschreibungstext | ...       ***
***    ... Anzeigetyp | Mussfeld-Kennzeichen | Buttongruppe-Kennung***
**********************************************************************

* Header-Strukturierung
  fill_attr '' 'Header überprüfen'(agh) 'G' ' ' ' '.
  fill_attr ah_sel_doc_header_position 'Position prüfen'(ahp) 'C' ' ' ' '.
  fill_attr ah_sel_doc_header_structure 'Struktur prüfen'(ahs) 'C' ' ' ' '.
  fill_attr ah_sel_doc_header_info_created 'Erstellereintrag prüfen (fehlt)'(ahe) 'C' ' ' ' '.
  fill_attr ah_sel_doc_header_info_changed 'Änderungseinträge prüfen (fehlt)'(aha) 'C' ' ' ' '.

* Code-Dokumentation
  fill_attr '' 'Code-Kommentierung überprüfen'(agk) 'G' ' ' ' '.

  fill_attr ah_sel_doc_blankline_level 'Leerzeilen: Schwelle (%):'(akl) ' ' ' ' ' '.
  fill_attr ah_sel_doc_blankline_levl_prio 'Bei Schwellenunterschreitung:'(aka) 'L' ' ' ' '.

  fill_attr ah_sel_doc_comment_level 'Kommentar: Schwelle (%):'(akk) ' ' ' ' ' '.
  fill_attr ah_sel_doc_comment_level_prio 'Bei Schwellenunterschreitung:'(aka) 'L' ' ' ' '.

ENDMETHOD.


METHOD fill_header_structure.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-17  rschilcher   Reinhard Schilcher                        *
*             Vergleichswert für Headerstruktur anlegen.             *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Fill_Header_Structure                                 ***
*** -> Initialisierung der Werte, die bei den Prüfungen zum        ***
***    Vergleichen des Headers herangezogen werden. Hier ist also  ***
***    der gewünschte Aufbau und Aussehen des Headers hinterlegt,  ***
***    auf den in der Prüfung "CHECK_DOC_HEADER" getestet werden   ***
***    soll.                                                       ***
**********************************************************************
*** => Die Erstellungs- und Änderungsinformationen dienen nur      ***
***    zur Darstellung im Parameterauswahlbildschirm. In der       ***
***    dazugehörigen Prüfung "CHECK_DOC_HEADER" findet jedoch      ***
***    keine Überprüfung dazu statt.                               ***
**********************************************************************

  DATA:

* Allgemeines
        h_text                        TYPE string,

        h_pos                         TYPE i.


**********************************************************************
*** Allgemeines                                                    ***
**********************************************************************

* Initialisierung
  CLEAR at_doc_header_structure.
  CLEAR at_doc_header_position.


**********************************************************************
*** Dokumentation: Header                                          ***
**********************************************************************

* Kennzeichen für den Header
  ah_doc_header_id = '* inconso AG'.


**********************************************************************
*** Dokumentation: Header: Startposition                           ***
**********************************************************************

* Die möglichen Startpositionen des Headers sollen geprüft werden ...
  IF ( ah_sel_doc_header_position = c_true ).

* Der Header soll in der erste Zeile beginnen
    h_pos = 1.
    APPEND h_pos TO at_doc_header_position.
  ENDIF.


**********************************************************************
*** Dokumentation: Header: Struktur                                ***
**********************************************************************

* Der Header-Grundaufbau soll geprüft werden ...
  IF ( ah_sel_doc_header_structure = c_true ).

    h_text = '*--------------------------------------------------------------------*'.
    APPEND h_text TO at_doc_header_structure.

    h_text = '* inconso AG                                                         *'.
    APPEND h_text TO at_doc_header_structure.

    h_text = '*--------------------------------------------------------------------*'.
    APPEND h_text TO at_doc_header_structure.

    h_text = '* Datum       Kürzel       Name                   Kommentar-Code     *'.
    APPEND h_text TO at_doc_header_structure.

    h_text = '*--------------------------------------------------------------------*'.
    APPEND h_text TO at_doc_header_structure.
  ENDIF.

ENDMETHOD.


METHOD fill_messages.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-20  rschilcher   Reinhard Schilcher                        *
*             Ergebnistexte für Ergebnisanzeige füllen.              *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Fill_Messages                                         ***
*** -> Zur jeweiligen Nachrichtennummer den passenden              ***
***    Nachrichtentext, Nachrichtentyp und Pseudokommentar anlegen,***
***    die dann als Prüfergebnis dem Benutzer angezeigt wird.      ***
**********************************************************************
*** => Systemmeldungen im Bereich: 0000 - 0099                     ***
***    Allgemeine Fehlermeldungen ab: 0100                         ***
***    Prüfungsmeldungen ab: 1000                                  ***
**********************************************************************
*** => Prüfungsmeldungen werden hier erstmal mit einer             ***
***    Grundzuordnung zum Ergebnisstatus angelegt (z.B. Fehler)    ***
***    und können dann später nachjustiert werden (z.B. Warnung).  ***                    ***
**********************************************************************
*** => ACHTUNG: Die IDs (Nachrichtennummern) müssen der Grösse     ***
***    nach passend (von klein "0" nach gross "9999") sortiert     ***
***    sein, sonst kommt es zu einem DUMP!                         ***
**********************************************************************

  DATA:

* Nachrichten
        lf_msg                        TYPE scimessage.


**********************************************************************
*** Macro zum Füllen eines Attributes                              ***
**********************************************************************

* Macro zum Füllen eines Attributes
  DEFINE fill_msg.

* Initialisierung
    clear lf_msg.

* Name dieser Klasse
    lf_msg-test = c_my_name.

* Nachrichtennr.
    lf_msg-code = &1.

* Nachrichtentyp (N = Info, W = Warnung, E = Fehler)
    lf_msg-kind = &2.

* Nachrichtentext
    lf_msg-text = &3.

* Pseudokommentar (im Code zum Unterdrücken einer Ergebnisausgabe, z.B. '#EC *')
    lf_msg-pcom = &4.

* Diese Nachricht zur Nachrichtenliste hinzufügen
    append lf_msg to scimessages.

  END-OF-DEFINITION.


**********************************************************************
*** Nachrichten für die GUI-Ausgabe füllen                         ***
*** -> Macro | Nachrichtennummer | Anzeigetyp | Anzeigetext |      ***
***    Pseudokommentar                                             ***
**********************************************************************


**********************************************************************
*** Allgemeine Fehlermeldungen (0100)                              ***
**********************************************************************

* -> Source Code-Aufbereitung misslungen. Keine Prüfungen! (&1 -> &2)
  fill_msg c_test_code_no_scan c_error text-e01 ' '.

* -> Fehler bei der Source Code-Aufbereitung. Keine Prüfungen! (&1 -> &2)
  fill_msg c_test_code_scan_error c_error text-e02 ' '.

* -> Keine Level-Infos für Prüfung vorhanden! Keine Prüfungen der Methode: &1 -> &2
  fill_msg c_test_code_no_level_info c_error text-e03 ' '.

* -> Kein Level-Name für Prüfung vorhanden! Keine Prüfungen der Methode: &1 -> &2
  fill_msg c_test_code_no_level_name c_error text-e04 ' '.

* -> Kein Source Code für Prüfung vorhanden! Keine Prüfungen der Methode: &1 -> &2
  fill_msg c_test_code_no_source c_error text-e05 ' '.


**********************************************************************
*** Prüfung: Header (1000)                                         ***
*** -> Demonstration möglicher Ausnahmen (Ausnahmetabelle und      ***
***    eigene Pseudokommentare z.B. '#EC CI_HDR_MULTI').           ***
**********************************************************************

* -> Kein Header gemäss Kennung gefunden.
  fill_msg c_test_code_hdr_no_header c_error text-p03 cl_ci_test_root=>c_exceptn_by_table_entry.

* -> Mehrere Header gemäss Kennung gefunden.
  fill_msg c_test_code_hdr_multi_header c_error text-p04 '#EC CI_HDR_MULTI'.

* -> Die Position des gefundenen Headers (Zeile: &3) passt nicht zu den vorgegebenen Header-Startpositionen.
  fill_msg c_test_code_hdr_no_position c_error text-p05 '#EC CI_HDR_POS'.

* -> Die Struktur des gefundenen Headers passt nicht zur vorgegebenen Struktur.
  fill_msg c_test_code_hdr_wrong_struct c_error text-p06 '#EC CI_HDR_STR'.


**********************************************************************
*** Prüfung: Code-Dokumentation (1100)                             ***
**********************************************************************

* -> Der Anteil an Leerzeilen (&3%) liegt unterhalb der eingestellten Schwelle (&4%).
  fill_msg c_test_code_blankline_proz c_note text-p01 ' '.

* -> Der Anteil an Kommentaren (&3%) liegt unterhalb der eingestellten Schwelle (&4%).
  fill_msg c_test_code_comment_proz c_note text-p02 cl_ci_test_root=>c_exceptn_imposibl.

ENDMETHOD.


METHOD get_attributes.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-15  rschilcher   Reinhard Schilcher                        *
*             Export der eingestellten Attribute.                    *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Get_Attributes                                        ***
*** -> Nach dem Einstellen der Attribute im Auswahlbildschirm      ***
***    durch den Benutzer werden die Attribute zu einem XString    ***
***    zusammengepackt.                                            ***
**********************************************************************
*** -> Der Einfachheit halber heissen die XString-Werte auf der    ***
***    linken Seite wie die Benutzereingabevariablen rechts.       ***
**********************************************************************

* Benutzereinstellungen exportieren
  EXPORT

* Header
    ah_sel_doc_header_info_changed = ah_sel_doc_header_info_changed
    ah_sel_doc_header_info_created = ah_sel_doc_header_info_created
    ah_sel_doc_header_position = ah_sel_doc_header_position
    ah_sel_doc_header_structure = ah_sel_doc_header_structure

* Kommentare
    ah_sel_doc_comment_level_prio = ah_sel_doc_comment_level_prio
    ah_sel_doc_comment_level = ah_sel_doc_comment_level

* Leerzeilen
    ah_sel_doc_blankline_levl_prio = ah_sel_doc_blankline_levl_prio
    ah_sel_doc_blankline_level = ah_sel_doc_blankline_level

   TO DATA BUFFER p_attributes.

ENDMETHOD.


METHOD if_ci_test~query_attributes.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-08  rschilcher   Reinhard Schilcher                        *
*             Attribute für die GUI-Ausgabe festlegen.               *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Query_Attributes                                      ***
*** -> Alle Einstellungsmöglichkeiten dieser Methode werden durch  ***
***    "Attribute" abgebildet, so dass sich der Benutzer die       ***
***    gewünschten Teil-Prüfungen heraussuchen und anhaken kann.   ***
**********************************************************************

* Klassendefinition sofort laden (nur vor EHP1 nötig)
*  CLASS cl_ci_query_attributes DEFINITION LOAD.

  DATA:

* Attribute
        lt_attribute                  TYPE sci_atttab,

* Allgemeines
        h_cancel                      TYPE sychar01.


**********************************************************************
*** Allgemeines                                                    ***
**********************************************************************

* Initialisierung
  CLEAR lt_attribute.

* Kennzeichen setzen
  attributes_ok = c_true.


**********************************************************************
*** Attribute für den Auswahlbildschirm                            ***
**********************************************************************

* Attribute für GUI-Ausgabe füllen
* -> Hiermit wird auch der Aufbau und somit das Aussehen des
*    Parameterauswahlbildschirms festgelegt.
  CALL METHOD fill_attributes
    IMPORTING
      pet_attribute = lt_attribute.

* Attribute sind vorhanden ...
  IF ( lt_attribute IS NOT INITIAL ).

* Mit den Attributen einen Auswahlbildschirm erstellen lassen
    CALL METHOD cl_ci_query_attributes=>generic
      EXPORTING
        p_name       = c_my_name
        p_title      = 'inconso AG Prüfungen einstellen'(at1)
        p_attributes = lt_attribute
        p_message    = ' '
        p_display    = ' '
      RECEIVING
        p_break      = h_cancel.

* Benutzer hat im Popup das "Exit"-Icon oder den "Abbruch"-Button gedrückt ...
    IF ( h_cancel = c_true ).

* Abbruch!
      RETURN.
    ENDIF.


**********************************************************************
*** Auswahlergebnis prüfen                                         ***
**********************************************************************

* Attributauswahl überprüfen
* -> Mindestens eine Prüfung muss angehakt sein!
    IF ( ah_sel_doc_header_position IS INITIAL )
      AND ( ah_sel_doc_header_structure IS INITIAL )
      AND ( ah_sel_doc_header_info_created IS INITIAL )
      AND ( ah_sel_doc_header_info_changed IS INITIAL )
      AND ( ah_sel_doc_blankline_level IS INITIAL )
      AND ( ah_sel_doc_comment_level IS INITIAL ).

* Speichern der Variante verhindern
      attributes_ok = c_false.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD put_attributes.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-15  rschilcher   Reinhard Schilcher                        *
*             Import der eingestellten Attribute.                    *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Put_Attributes                                        ***
*** -> Die auf dem SAP-System hinterlegten Attribute mit den       ***
***    Einstellungen des Benutzers werden für die Prüfungen        ***
***    aus dem XString geladen.                                    ***
**********************************************************************
*** -> Der Einfachheit halber heissen die Prüfungsvariablen rechts ***
***    genauso wie die XString-Werte auf linken Seite.             ***
**********************************************************************

* Alle Daten importieren
  IMPORT

* Header
    ah_sel_doc_header_info_changed = ah_sel_doc_header_info_changed
    ah_sel_doc_header_info_created = ah_sel_doc_header_info_created
    ah_sel_doc_header_position = ah_sel_doc_header_position
    ah_sel_doc_header_structure = ah_sel_doc_header_structure

* Kommentare
    ah_sel_doc_comment_level_prio = ah_sel_doc_comment_level_prio
    ah_sel_doc_comment_level = ah_sel_doc_comment_level

* Leerzeilen
    ah_sel_doc_blankline_levl_prio = ah_sel_doc_blankline_levl_prio
    ah_sel_doc_blankline_level = ah_sel_doc_blankline_level

   FROM DATA BUFFER p_attributes.

ENDMETHOD.


METHOD run.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-18  rschilcher   Reinhard Schilcher                        *
*             Hauptverwaltung für eigene Prüfungen.                  *
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Run                                                   ***
*** -> Zentraler Hook für eigene Code Inspector Prüfungen. Hier    ***
***    wird zu den verschiedenen Prüfungen abgesprungen.           ***
**********************************************************************

  TYPE-POOLS: scan.

  DATA:

* Source Code
        h_result                      TYPE sychar01.

  FIELD-SYMBOLS:

* Nachrichten
        <fs_msg>                      TYPE scimessage,

* Aufbereitung: Level
        <fs_levels>                   TYPE slevel.


**********************************************************************
*** Source Code-Aufbereitung für Prüfungen                         ***
**********************************************************************

* Es wurde noch keine Code-Aufbereitung erzeugt ...
  IF ( ref_scan IS INITIAL ).

* Code-Aufbereitung erzeugen lassen
    CALL METHOD get
      RECEIVING
        p_result = h_result.

* Code-Aufbereitung misslungen
    IF ( h_result <> 'X' ) .

* Fehlermeldung (keine Prüfung möglich)
      CALL METHOD inform
        EXPORTING
          p_test    = c_my_name
          p_code    = c_test_code_no_scan
          p_param_1 = c_my_name
          p_param_2 = 'Run'.

* Kann nicht prüfen -> Abbruch!
      RETURN.
    ENDIF.
  ENDIF.

* Source Code-Aufbereitung war fehlerhaft ...
  IF ( ref_scan->subrc <> 0 ).

* Fehlermeldung (Code-Aufbereitung fehlerhaft)
    CALL METHOD inform
      EXPORTING
        p_test    = c_my_name
        p_code    = c_test_code_scan_error
        p_param_1 = c_my_name
        p_param_2 = 'Run'.

* Kann nicht prüfen -> Abbruch!
    RETURN.
  ENDIF.


**********************************************************************
*** Nachrichten nachjustieren                                      ***
**********************************************************************

* Leerzeilen: Anteil der Leerzeilen am Gesamtcode
  READ TABLE scimessages ASSIGNING <fs_msg>             "#EC CI_SORTSEQ
    WITH KEY code = c_test_code_blankline_proz.

* Nachricht ist vorhanden ...
  IF ( <fs_msg> IS ASSIGNED ).

* Vom Benutzer gewählte Ausgabestufe umsetzen
    IF ( ah_sel_doc_blankline_levl_prio = 3 ).
      <fs_msg>-kind = c_error.
    ELSEIF ( ah_sel_doc_blankline_levl_prio = 2 ).
      <fs_msg>-kind = c_warning.
    ELSE.
      <fs_msg>-kind = c_note.
    ENDIF.
  ENDIF.

* Kommentare: Anteil der Kommentare am Gesamtcode
  READ TABLE scimessages ASSIGNING <fs_msg>             "#EC CI_SORTSEQ
    WITH KEY code = c_test_code_comment_proz.

* Nachricht ist vorhanden ...
  IF ( <fs_msg> IS ASSIGNED ).

* Vom Benutzer gewählte Ausgabestufe umsetzen
    IF ( ah_sel_doc_comment_level_prio = 3 ).
      <fs_msg>-kind = c_error.
    ELSEIF ( ah_sel_doc_comment_level_prio = 2 ).
      <fs_msg>-kind = c_warning.
    ELSE.
      <fs_msg>-kind = c_note.
    ENDIF.
  ENDIF.


**********************************************************************
*** Vergleichswerte für Prüfung                                    ***
**********************************************************************

* Headerstruktur für Prüfung als Vergleichswert füllen
  CALL METHOD fill_header_structure.


**********************************************************************
*** Verteiler auf die verschiedenen Prüfungen                      ***
**********************************************************************
*** -> Je nach Typ des Source Codes (Report, Methode, Macro ...)   ***
***    wird zu den jeweiligen Prüfmethoden verzweigt.              ***
**********************************************************************

* Die verschiedenen Hierarchiestufen abklappern
  LOOP AT ref_scan->levels ASSIGNING <fs_levels>.

* Nur Programmtypen bearbeiten (Reports, Includes, Methoden etc.)
    IF ( <fs_levels>-type = scan_level_type-program ).

* Es ist eine Klasse ...
* (Abfrage nur zu Demozwecken)
      IF ( <fs_levels>-name+30(1) = 'C' ).

* Es ist eine Klassenmethode ...
* (Abfrage nur zu Demozwecken)
        IF ( <fs_levels>-name+30(2) = 'CM' ).

* Prüfung: Header
          CALL METHOD check_doc_header
            EXPORTING
              pif_level = <fs_levels>.

* Prüfung: Code-Documentation
          CALL METHOD check_doc_comment
            EXPORTING
              pif_level = <fs_levels>.

* Keine Klassenmethode, z.B. Public Section ...
        ELSE.

* Nix tun!

        ENDIF.

* Es ist keine Klasse (nicht OO) ...
* (Abfrage nur zu Demozwecken)
* -> z.B. Report, Includes, Funktionsbaustein etc.
      ELSE.

* Prüfung: Header
        CALL METHOD check_doc_header
          EXPORTING
            pif_level = <fs_levels>.

* Prüfung: Code-Documentation
        CALL METHOD check_doc_comment
          EXPORTING
            pif_level = <fs_levels>.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDMETHOD.
ENDCLASS.
