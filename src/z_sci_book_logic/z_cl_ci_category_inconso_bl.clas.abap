class Z_CL_CI_CATEGORY_INCONSO_BL definition
  public
  inheriting from CL_CI_CATEGORY_ROOT
  final
  create public .

*"* public components of class Z_CL_CI_CATEGORY_INCONSO_BL
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .
protected section.
*"* protected components of class CL_CI_CATEGORY_SLIN
*"* do not include other source files here!!!
private section.
*"* private components of class CL_CI_CATEGORY_TEMPLATE
*"* do not include other source files here!!!
ENDCLASS.



CLASS Z_CL_CI_CATEGORY_INCONSO_BL IMPLEMENTATION.


METHOD constructor .
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2009-04-08  rschilcher   Reinhard Schilcher                        *
*             Ordner für inconso AG Prüfung "Programmierrichtlinien".*
*--------------------------------------------------------------------*




**********************************************************************
*** Methode: Constructor                                           ***
*** -> Initiales Anlegen eines Baum-Eintrages, hier: Ordner.       ***
**********************************************************************

* Übergeordnete Methode aufrufen
  super->constructor( ).

* Namen des Eintrags im Auswahlbaum
  description = 'inconso AG Programmierrichtlinien'(000).

* Kategorie (Klassenname) des übergeordneten Eintrags
  category    = 'CL_CI_CATEGORY_TOP'.

* Position im Auswahlbaum, an der der Eintrag erscheinen soll
  position    = '991'.

ENDMETHOD.
ENDCLASS.
