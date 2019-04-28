*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2010-10-04  fruggaber    Frank Ruggaber                            *
*             Demoprogramm zum Test durch eine SCI Inspektion        *
*             In diesem Report finden Sie u.a. auch die Listings aus *
*             Kapitel 2.                                             *
**********************************************************************

REPORT  z_demo_sci_inspektion.

**********************************************************************
*** Beispiele für Code bei dem die DEFAULT-Prüfvariante des
*** Code Inspectors Meldungen erzeugt
**********************************************************************

DATA:
      lt_t100 TYPE STANDARD TABLE OF t100,
      lt_nast TYPE STANDARD TABLE OF nast.

* Beispiel einer Selektion ohne Where-Bedingung (gepuffert)
SELECT * FROM t100
  INTO TABLE lt_t100.

* Beispiel einer Selektion ohne Where-Bedingung (ungepuffert)
SELECT * FROM nast
  INTO TABLE lt_nast.


**********************************************************************
*** Listing 2.4
*** Beispielcode mit Pseudokommentar
**********************************************************************
DATA:
      lt_snap TYPE STANDARD TABLE OF snap.

SELECT * INTO TABLE lt_snap
  FROM snap.                    "#EC CI_NOWHERE Test Meldung ausblenden


**********************************************************************
*** Listing 2.5
*** Codebeispiel für das Genehmigungsverfahren
**********************************************************************

DATA:
      lt_lines TYPE string_table.

INSERT REPORT 'Z_SCI_DEMO'
  FROM lt_lines UNICODE ENABLING 'X'.
