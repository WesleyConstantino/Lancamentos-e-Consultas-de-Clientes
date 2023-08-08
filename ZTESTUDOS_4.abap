REPORT zestudos_2.

*&---------------------------------------------------------------------*
*                            Tabelas                                   *
*&---------------------------------------------------------------------*
TABLES: ZTESTUDOS_4.

*&---------------------------------------------------------------------*
*                             Types                                    *
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_out,
    nome       TYPE ZTESTUDOS_4-nome,
    produto    TYPE ZTESTUDOS_4-produto,
    valor_prod TYPE ZTESTUDOS_4-valor_prod,
    cod_cli    TYPE ZTESTUDOS_4-cod_cli,
    ativo      TYPE ZTESTUDOS_4-ativo,
  END OF ty_out.

*&---------------------------------------------------------------------*
*                        Tabelas  Internas                             *
*&---------------------------------------------------------------------*
DATA: t_ZTESTUDOS_4   TYPE TABLE OF ZTESTUDOS_4,
      t_out           TYPE TABLE OF ty_out.

*&---------------------------------------------------------------------*
*                             Workareas                                *
*&---------------------------------------------------------------------*
DATA: wa_ZTESTUDOS_4  LIKE LINE OF t_ZTESTUDOS_4,
      wa_out          LIKE LINE OF t_out.

*&---------------------------------------------------------------------*
*                       Declaração de Tipos                            *
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

*&---------------------------------------------------------------------*
*                        Estruturas do ALV                             *
*&---------------------------------------------------------------------*
DATA: lo_container_100  TYPE REF TO cl_gui_custom_container,
      lo_container_100b TYPE REF TO cl_gui_custom_container,
      lo_grid_100       TYPE REF TO cl_gui_alv_grid,
      lo_grid_100b      TYPE REF TO cl_gui_alv_grid,
      lv_okcode_100     TYPE sy-ucomm,
      lt_fieldcat       TYPE lvc_t_fcat,
      lt_fieldcatb      TYPE lvc_t_fcat,
      ls_layout         TYPE lvc_s_layo,
      ls_variant        TYPE disvariant.

*&---------------------------------------------------------------------*
*                         Tela de seleção                              *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-000.
PARAMETERS: p_cod TYPE ZTESTUDOS_4-cod_cli  MODIF ID cod,  "Modifico o ID dos campos que quero eventualmente ocultar com "MODIF ID".
            p_nome TYPE ZTESTUDOS_4-nome MODIF ID nom.

*Radio Buttons
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_consu RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND comando.
SELECTION-SCREEN COMMENT 5(9) TEXT-003 FOR FIELD rb_consu.
PARAMETERS: rb_lanca RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 19(6) TEXT-004 FOR FIELD rb_lanca.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b0.

*Evento para reconhecer os ciques do radiobutton e mudar as telas
AT SELECTION-SCREEN OUTPUT.
  PERFORM zf_modifica_tela.

*Início da execusão
START-OF-SELECTION.
 IF rb_consu EQ 'X'.
   PERFORM: zf_select.
 ELSE.
  PERFORM: zf_update.
 ENDIF.

*&---------------------------------------------------------------------*
*&      Form  zf_update
*&---------------------------------------------------------------------*
FORM zf_update.
 CLEAR: wa_ZTESTUDOS_4.

wa_ZTESTUDOS_4-nome = p_nome.
PERFORM zf_monta_codigo_automatico.

IF wa_ZTESTUDOS_4-nome IS NOT INITIAL.
    "Update
      INSERT ZTESTUDOS_4 FROM wa_ZTESTUDOS_4.
      CLEAR  wa_ZTESTUDOS_4.
    "Commit
     IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT. "COMMIT WORK AND WAIT dá commit no banco de dados

      MESSAGE s208(00) WITH 'SALVO COM SUCESSO!'.
    ELSE.
      ROLLBACK WORK. "ROLLBACK WORK desfaz tudo o que aconteceu na operação
      MESSAGE s208(00) WITH  'ERRO AO GRAVAR!' DISPLAY LIKE 'E'.
    ENDIF.

    CLEAR: p_nome.
ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  zf_monta_codigo_automatico
*&---------------------------------------------------------------------*
FORM zf_monta_codigo_automatico.

  SELECT MAX( cod_cli )
   FROM ZTESTUDOS_4
   INTO @DATA(v_cod_cli).

ADD 1 TO v_cod_cli.

wa_ZTESTUDOS_4-cod_cli = v_cod_cli.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT
*&---------------------------------------------------------------------*
FORM zf_select.

   SELECT *
   FROM ZTESTUDOS_4
   INTO TABLE t_ZTESTUDOS_4
     WHERE cod_cli = p_cod.

     IF t_ZTESTUDOS_4 IS NOT INITIAL.
      PERFORM: zf_monta_t_out,
               zf_show_alv_poo.
     ELSE.
      MESSAGE 'Código inesistente!' TYPE 'S' DISPLAY LIKE 'W'.
     ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  zf_monta_t_out
*&---------------------------------------------------------------------*
FORM zf_monta_t_out.

  LOOP AT t_ZTESTUDOS_4 INTO wa_ZTESTUDOS_4.
  IF wa_out-nome IS INITIAL.
   wa_out-nome = wa_ZTESTUDOS_4-nome.
   wa_out-cod_cli = wa_ZTESTUDOS_4-cod_cli.
   wa_out-ativo = wa_ZTESTUDOS_4-ativo.
  ENDIF.
   wa_out-produto = wa_ZTESTUDOS_4-produto.
   wa_out-valor_prod = wa_ZTESTUDOS_4-valor_prod.

   IF wa_out-produto IS INITIAL.
    wa_out-produto = 'Não há produtos.'.
   ENDIF.

  APPEND wa_out TO t_out.
  CLEAR: wa_out,
         wa_ZTESTUDOS_4.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_show_alv_poo
*&---------------------------------------------------------------------*
FORM zf_show_alv_poo.

  DATA: lo_table   TYPE REF TO cl_salv_table,              "Acessar a classe "cl_salv_table"
        lo_header  TYPE REF TO cl_salv_form_layout_grid,   "Para criação do header
        lo_columns TYPE REF TO cl_salv_columns_table.      "Ajustar tamanho dos subtítulos

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_table "Tabela local
                             CHANGING t_table = t_out ).

      lo_table->get_functions( )->set_all( abap_true ). "Ativar met codes

*Mudar nome das colunas do ALV
      lo_table->get_columns( )->get_column( 'NOME' )->set_short_text( 'Nome' ).
      lo_table->get_columns( )->get_column( 'NOME' )->set_medium_text( 'Nome' ).
      lo_table->get_columns( )->get_column( 'NOME' )->set_long_text( 'Nome' ).

      lo_table->get_columns( )->get_column( 'PRODUTO' )->set_short_text( 'Produtos' ).
      lo_table->get_columns( )->get_column( 'PRODUTO' )->set_medium_text( 'Produtos' ).
      lo_table->get_columns( )->get_column( 'PRODUTO' )->set_long_text( 'Produtos' ).

      lo_table->get_columns( )->get_column( 'VALOR_PROD' )->set_short_text( 'Valor' ).
      lo_table->get_columns( )->get_column( 'VALOR_PROD' )->set_medium_text( 'Valor Total' ).
      lo_table->get_columns( )->get_column( 'VALOR_PROD' )->set_long_text( 'Valor Total' ).

      lo_table->get_columns( )->get_column( 'COD_CLI' )->set_short_text( 'Código' ).
      lo_table->get_columns( )->get_column( 'COD_CLI' )->set_medium_text( 'Código do cliente' ).
      lo_table->get_columns( )->get_column( 'COD_CLI' )->set_long_text( 'Código do cliente' ).

      lo_table->get_columns( )->get_column( 'ATIVO' )->set_short_text( 'Ativo' ).
      lo_table->get_columns( )->get_column( 'ATIVO' )->set_medium_text( 'Ativo' ).
      lo_table->get_columns( )->get_column( 'ATIVO' )->set_long_text( 'Ativo' ).

      CREATE OBJECT lo_header. "É necessário que criemos o objeto header

*Mudar título do header
        lo_header->create_header_information( row = 1 column = 1 text = 'Relatório ALV' ).


      lo_header->add_row( ).


      lo_table->get_display_settings( )->set_striped_pattern( abap_true ).

      lo_table->set_top_of_list( lo_header ).

      lo_columns = lo_table->get_columns( ). "Ajustar tamanho dos subtítulos
      lo_columns->set_optimize( abap_true ). "Ajustar tamanho dos subtítulos

      lo_table->display( ) . "O dispay é fundamental para a exibição do ALV

    CATCH cx_salv_msg
          cx_root.

      MESSAGE s398(00) WITH 'Erro ao exibir tabela' DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  MODIFICA_TELA
*&---------------------------------------------------------------------*
FORM zf_modifica_tela .
  LOOP AT SCREEN.  "Faço um LOOP AT na tela "SCREEN"
*Lançar
    IF rb_lanca EQ 'X'.
      IF screen-group1 EQ 'NOM'.
        screen-invisible = 0.
        screen-input     = 1.
        screen-active    = 1.
      ENDIF.

      IF screen-group1 EQ 'COD'.
        screen-invisible = 1.
        screen-input     = 0.
        screen-active    = 0.
      ENDIF.
    ENDIF.

*Consultar
    IF rb_consu EQ 'X'.
      IF screen-group1 EQ 'COD'.
        screen-invisible = 0.
        screen-input     = 1.
        screen-active    = 1.
      ENDIF.

      IF screen-group1 EQ 'NOM'.
        screen-invisible = 1.
        screen-input     = 0.
        screen-active    = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN. "Preciso dar um MODIFY SCREEN para que funcione.
  ENDLOOP.
ENDFORM.
