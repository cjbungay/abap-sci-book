class ZCL_IM__CTS_REQUEST_CHECK definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM__CTS_REQUEST_CHECK
*"* do not include other source files here!!!

  interfaces IF_EX_CTS_REQUEST_CHECK .
protected section.
*"* protected components of class ZCL_IM__CTS_REQUEST_CHECK
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM__CTS_REQUEST_CHECK
*"* do not include other source files here!!!

  methods SCI_CHECK
    importing
      !REQUEST type TRKORR
      !OBJECTS type TR_OBJECTS optional
    exceptions
      CANCEL .
ENDCLASS.



CLASS ZCL_IM__CTS_REQUEST_CHECK IMPLEMENTATION.


method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_ADD_OBJECTS.
endmethod.


method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_CHANGING_OWNER.
endmethod.


method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_CREATION.
endmethod.


METHOD if_ex_cts_request_check~check_before_release.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2011-02-16  fruggaber    Frank Ruggaber                            *
*             Diese Methode wird vor Freigabe eines Transportauftrags*
*             oder einer Aufgabe eines Transportauftrags durchlaufen.*
*             An dieser Stelle werden wir, wie in Kapitel 3          *
*             beschrieben, vor der Freigabe einer Aufgabe eines      *
*             Transportauftrags, die Objekte des Auftrags mit dem    *
*             SAP Code Inspector prüfen.                             *
*             Diese Methode entspricht dem Listing 3.1               *
**********************************************************************



  DATA:
        lf_e070 TYPE e070
        .

* Zuerst müssen wir prüfen, ob es sich um die Freigabe eines
* Transportauftrags oder einer Aufgabe eines Transportauftrags
* handelt. Dies lässt sich ganz einfach herausfinden, in dem
* wir in der Tabelle der Header von Transportaufträgen bzw. Aufgaben
* prüfen, ob es zum aktuellen Auftrag (Parameter REQUEST) einen
* übergeordneten Auftrag gibt. Ist dies der Fall, dann handelt es
* sich um eine Aufgabe eines Transportauftrags
  SELECT SINGLE * INTO lf_e070
    FROM e070
    WHERE trkorr = request.
  IF sy-subrc <> 0.
*   Fehlerhandling
    MESSAGE i001(zsci) WITH request.
*   Zum TA &1 konnte kein Header gefunden werden!
    RAISE cancel.
  ENDIF.

* Prüfen, ob es sich um eine Aufgabe eines Transportauftrags handelt
  IF lf_e070-strkorr IS NOT INITIAL.
*   in diesem Fall wollen wir für alle Objekte der Aufgabe
*   eine Code-Inspector-Inspektion durchführen
    CALL METHOD me->sci_check
      EXPORTING
        request = request
        objects = objects
      EXCEPTIONS
        cancel  = 1
        OTHERS  = 2.
    IF sy-subrc <> 0.
*     ein RAISE CANCEL in der Methode SCI_CHECK
*     wird hier direkt weitergereicht, damit die
*     Freigabe des Transportauftrags abgerochen wird
      RAISE cancel.
    ENDIF.

  ENDIF.

ENDMETHOD.


  method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_RELEASE_SLIN.
  endmethod.


METHOD sci_check.
*--------------------------------------------------------------------*
* inconso AG                                                         *
*--------------------------------------------------------------------*
* Datum       Kürzel       Name                   Kommentar-Code     *
*--------------------------------------------------------------------*
* 2011-02-16  fruggaber    Frank Ruggaber                            *
*             Beispielimplementierung die bei der Friageb einer      *
*             Transportaufgabe eine Code Inspector Inspektion        *
*             durchführt.                                            *
*             Diese Methode entspricht den Listings 3.2 - 3.6        *
**********************************************************************



  DATA:
        h_sci_chkv TYPE sci_chkv,
        h_user TYPE sci_user,
        lr_ci_checkvariant TYPE REF TO cl_ci_checkvariant,
        lr_ci_objectset TYPE REF TO cl_ci_objectset,
        lr_ci_inspection TYPE REF TO cl_ci_inspection,
        lr_ci_tests TYPE REF TO cl_ci_tests
        .


**********************************************************************
* Prüfvariante
* Listing 3.2
**********************************************************************
* In diesem Beispiel verwenden wir die globale Prüfvariante Z_TEST.
* Wenn Sie eine andere Prüfvariante verwenden wollen,
* dann können Sie diese in der Variablen h_sci_chkv mitgeben
  h_sci_chkv = 'Z_TEST'.

* Der Parameter p_user muss bei lokalen Prüfvarianten
* den SAP Benutzernamen des Erstellers der Prüfvariante beinhalten.
* Also z.B. h_user = 'FRUGGABER'.
* Bei globalen Prüfvarianten bleibt dieser Parameter leer
  CLEAR h_user.

* Instanz der entsprechenden Prüfvariante erzeugen
  CALL METHOD cl_ci_checkvariant=>get_ref
    EXPORTING
      p_user            = h_user "bei lokaler Prüfv. Name des Erstellers
      p_name            = h_sci_chkv "Name der Prüfvariante
    RECEIVING
      p_ref             = lr_ci_checkvariant
    EXCEPTIONS
      chkv_not_exists   = 1
      missing_parameter = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    IF sy-subrc = 1.
      MESSAGE i003(zsci) WITH h_sci_chkv.
*   Die angegebene Prüfvariante &1 existiert nicht.
    ELSEIF sy-subrc <> 0.
      MESSAGE i004(zsci) WITH h_sci_chkv.
*   Fehler beim Ermitteln der Prüfvariante &1
    ENDIF.
    RAISE cancel.
  ENDIF.

**********************************************************************
* Objektmenge
* Listing 3.3
**********************************************************************
* Referenz auf die Code Inspector Objektmenge erzeugen
  CALL METHOD cl_ci_objectset=>get_ref
    EXPORTING
      p_type                    = cl_ci_objectset=>c_0kor "Objekttyp 'Auftrag'
      p_korr                    = request " Nummer der Aufgabe des TAs
    RECEIVING
      p_ref                     = lr_ci_objectset
    EXCEPTIONS
      missing_parameter         = 1
      objs_not_exists           = 2
      invalid_request           = 3
      object_not_exists         = 4
      object_may_not_be_checked = 5
      no_main_program           = 6
      OTHERS                    = 7.
  IF sy-subrc <> 0.
    MESSAGE i005(zsci) WITH request.
*   Fehler beim Ermitteln der Objektmenge für Transportauftrag &1
    RAISE cancel.
  ENDIF.

* Prüfen, ob es überhaupt Objekte in der SCI Objektmenge gibt
  IF lr_ci_objectset->iobjlst-objects[] IS INITIAL.
*   in diesem Fall kann auch nichts geprüft werden
*   und somit die Freigabe des Transportauftrags fortgesetzt werden
    RETURN.
  ENDIF.

**********************************************************************
* Inspektion
* Listing 3.4
**********************************************************************
* Letztendlich müssen wir eine Referenz auf die SCI Inspektion erzeugen.
* Die Parameter P_USER, P_NAME und P_TEXT könne gefüllt werden,
* wenn Sie dei Inspektion auch aus der Transaktion SCI heraus
* aufrufen wollen
  CALL METHOD cl_ci_inspection=>create
    EXPORTING
      p_user              = space " Ersteller
      p_name              = space " Name der Inspektion
*     p_text              =  " Beschreibung der Inspektion
    RECEIVING
      p_ref               = lr_ci_inspection
    EXCEPTIONS
      insp_already_exists = 1
      insp_not_exists     = 2
      locked              = 3
      error_in_enqueue    = 4
      not_authorized      = 5
      limit_reached       = 6
      OTHERS              = 7.
  IF sy-subrc <> 0.
    MESSAGE i006(zsci) WITH request.
*   Fehler beim Erzeugen der Inspektion für Transportauftrag &1
    RAISE cancel.
  ENDIF.

* Der Inspektion müssen wir dann noch die Prüfvariante und
* die Objektmenge mitgeben
  CALL METHOD lr_ci_inspection->set
    EXPORTING
      p_chkv       = lr_ci_checkvariant
      p_objs       = lr_ci_objectset
    EXCEPTIONS
      not_enqueued = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE i007(zsci) WITH request.
*   Fehler beim Setzen der Prüfv./Objektm. zur Inspektion TA &1
    RAISE cancel.
  ENDIF.

**********************************************************************
* Inspektion ausführen
* Listing 3.5
**********************************************************************

* damit die Inspektion auch erneut ausgeführt werden kann,
* müssen wir die Methode 'ENABLE_RERUN' für die Instanz aufrufen
  lr_ci_inspection->enable_rerun( ).

* Und schließlich müssen wir die Inspektion durchführen
* (weitere Informationen zur RUN-Methode finden Sie in Kapitel 4)
  CALL METHOD lr_ci_inspection->run
    EXPORTING
      p_howtorun             = 'D' "für direktes ausführen
    EXCEPTIONS
      missing_information    = 1
      cancel_popup           = 2
      insp_already_run       = 3
      no_object              = 4
      too_many_objects       = 5
      could_not_read_variant = 6
      locked                 = 7
      objs_locked            = 8
      error_in_objs_build    = 9
      invalid_check_version  = 10
      just_running           = 11
      error_in_batch         = 12
      not_authorized         = 13
      no_server_found        = 14
      OTHERS                 = 15.
  IF sy-subrc <> 0.
    MESSAGE i008(zsci) WITH request.
*   Fehler beim Durchführen der Inspektion für Transportauftrag &1
    RAISE cancel.
  ENDIF.

**********************************************************************
* Anzeige der Prüfergebnisse
* Listing 3.6
**********************************************************************
* Dazu wollen wir die Ergebnisse auswerten und prüfen, ob Meldungen
* (Fehler oder Warnungen) aufgetreten sind
  CALL METHOD cl_ci_tests=>get_result_tree
    EXPORTING
      p_insp_ref         = lr_ci_inspection
    RECEIVING
      p_tree             = lr_ci_tests
    EXCEPTIONS
      invalid_results    = 1
      invalid_category   = 2
      invalid_class_name = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    MESSAGE i009(zsci) WITH request.
*   Fehler beim Ermitteln des Ergebnis zur Inspektion für TA &1
    RAISE cancel.
  ENDIF.

* Prüfen, ob Fehler oder Warnungen aufgetreten sind
  IF lr_ci_tests IS BOUND.
    IF lr_ci_tests->tree->err_cnt IS NOT INITIAL
      OR lr_ci_tests->tree->warn_cnt IS NOT INITIAL.
*     In diesem Fall eine Infomeldung ...
      MESSAGE i002(zsci).
*   Bei der Code Inspector Prüfung sind Warnungen/Fehler aufgetreten!

*     ...und die Prüfergebnisse ausgeben
      CALL FUNCTION 'SCI_SHOW_RESULTS'
        EXPORTING
          p_insp_ref = lr_ci_inspection.

*     ...und die Freigabe abbrechen
      RAISE cancel.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
