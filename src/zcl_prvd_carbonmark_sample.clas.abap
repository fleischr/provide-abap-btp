CLASS zcl_prvd_carbonmark_sample DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS: c_ident_basic_auth         TYPE string VALUE '/api/v1/authenticate',
               c_ident_access_token_req   TYPE string VALUE '/api/v1/tokens',
               c_vault_list               TYPE string VALUE '/api/v1/vaults',
               c_vault_key_list           TYPE string VALUE '/api/v1/vaults/{vaultid}/keys',
               c_vault_signing            TYPE string VALUE '/api/v1/vaults/{vaultid}/keys/{keyid}/sign',
               c_carbonmark_ret_req       TYPE string VALUE '/api/v1/eco/retire_carbon_requests',
               c_carbonmark_ret_broadcast TYPE string VALUE '/api/v1/eco/retire_carbon_requests/{requestid}/retire',
               c_usdc_polygon_address     TYPE string VALUE '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
               c_toucan_bct_address       TYPE string VALUE '0x2f800db0fdb5223b3c3f354886d907a671414a7f',
               c_prvd_polygon_networkid   TYPE string VALUE '2fd61fde-5031-41f1-86b8-8a72e2945ead'.
    TYPES: BEGIN OF ty_prvd_ident_basicauth,
             email    TYPE string,
             password TYPE string,
           END OF ty_prvd_ident_basicauth,
           BEGIN OF ty_prvd_sessionaccesstoken_req,
             user_id         TYPE string,
             organization_id TYPE string,
           END OF ty_prvd_sessionaccesstoken_req,
           BEGIN OF ty_carbon_ret_request,
             network_id                    TYPE string,
             description                   TYPE string,
             value                         TYPE p LENGTH 16 DECIMALS 9,
             source_token_contract_address TYPE string,
             pool_token_contract_address   TYPE string,
             beneficiary_address           TYPE string,
             beneficiary_name              TYPE string,
             retirement_message            TYPE string,
           END OF ty_carbon_ret_request,
           BEGIN OF ty_vault_sign_request,
             message TYPE string,
           END OF ty_vault_sign_request,
           BEGIN OF ty_vault_sign_response,
             signature TYPE string,
           END OF ty_vault_sign_response,
           BEGIN OF ty_carbon_req_broadcast,
             data       TYPE string,
             request_id TYPE string,
             signature  TYPE string,
             signer     TYPE string,
           END OF ty_carbon_req_broadcast.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
    DATA: mv_prvd_access_jwt TYPE string.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prvd_carbonmark_sample IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    TRY.
        "Provide API destinations
        DATA(lo_prvdbtp_ident) = cl_http_destination_provider=>create_by_url( 'https://ident.provide.technology' ).
        DATA(lo_prvdbtp_vault) = cl_http_destination_provider=>create_by_url( 'https://vault.provide.technology' ).
        "Payments gateway
        DATA(lo_payments_gateway) = cl_http_destination_provider=>create_by_url( 'https://api.providepayments.com' ).

        "HTTP clients
        DATA(lo_prvdbtp_ident_http) = cl_web_http_client_manager=>create_by_http_destination( lo_prvdbtp_ident ).
        DATA(lo_prvdbtp_vault_http) = cl_web_http_client_manager=>create_by_http_destination( lo_prvdbtp_vault ).
        DATA(lo_payments_gateway_http) = cl_web_http_client_manager=>create_by_http_destination( lo_payments_gateway ).

        "Authenticate and get access token
        DATA(ls_authenticate_req) = VALUE ty_prvd_ident_basicauth( ).
        ls_authenticate_req-email = ''. "Shuttle email
        ls_authenticate_req-password = ''. "Shuttle password

        DATA(lo_ident_http_req) = lo_prvdbtp_ident_http->get_http_request( ).
        DATA(lv_ident_json_body) = /ui2/cl_json=>serialize( ls_authenticate_req ).

        lo_ident_http_req->set_header_fields( VALUE #(
          ( name = 'Content-Type'
            value = 'application/json' )
          ( name = 'Content-Length'
            value = strlen( lv_ident_json_body ) ) ) ).

        lo_ident_http_req->set_text( i_text = CONV #( lv_ident_json_body )
                           i_length = strlen( lv_ident_json_body ) ).

        DATA(lo_prvdbtp_ident_response1) = lo_prvdbtp_ident_http->execute( if_web_http_client=>get ).

        "/ui2/cl_json=>deserialize(
        "  EXPORTING
        "    json = lo_prvdbtp_ident_response1->get_text( )
        "  CHANGING
        "    data = token ).

        DATA(ls_accesstoken_req) = VALUE ty_prvd_sessionaccesstoken_req( ).
        ls_accesstoken_req-user_id = ''.
        ls_accesstoken_req-organization_id = ''.

        "Get details of the vault
        DATA(lo_vault_http_req) = lo_prvdbtp_vault_http->get_http_request( ).
        DATA(lv_prvd_user_walletid) = ''.

        "DATA(response) = http_client->execute( if_web_http_client=>get ).
        "result = response->get_text( ).

        "Setup carbon retirement request
        DATA(lo_payments_gateway_http_req) = lo_payments_gateway_http->get_http_request( ).
        DATA(ls_carbon_ret_request) = value ty_carbon_ret_request( ).
        ls_carbon_ret_request-network_id = c_prvd_polygon_networkid.
        ls_carbon_ret_request-description = 'Sample retirement with ABAP Steampunk - SAP BTP'.
        ls_carbon_ret_request-retirement_message = 'Sample retirement with ABAP Steampunk - SAP BTP'.
        ls_carbon_ret_request-source_token_contract_address = c_usdc_polygon_address.
        ls_carbon_ret_request-pool_token_contract_address = c_toucan_bct_address.
        ls_carbon_ret_request-value = '0.001'.
        ls_carbon_ret_request-beneficiary_name = 'ABAP Steampunk Pro'.
        ls_carbon_ret_request-beneficiary_address = lv_prvd_user_walletid.
        DATA(lv_carbon_ret_req_json_body) = /ui2/cl_json=>serialize( ls_carbon_ret_request ).

        "lv_carbon_ret_req_json_body->set_header_fields( VALUE #(
        "  ( name = 'Content-Type'
        "    value = 'application/json' )
        "  ( name = 'Content-Length'
        "    value = strlen( json_body ) ) ) ).

        lo_payments_gateway_http_req->set_text( i_text = CONV #( lv_carbon_ret_req_json_body )
                           i_length = strlen( lv_carbon_ret_req_json_body ) ).

        "DATA(response) = http_client->execute( if_web_http_client=>get ).
        "result = response->get_text( ).


        "Sign transaction
        DATA(ls_vault_sign_req) = value ty_vault_sign_request( ).
        ls_vault_sign_req-message = ''.

        "request->set_header_fields( VALUE #(
        "  ( name = 'Content-Type'
        "    value = 'application/json' )
        "  ( name = 'Content-Length'
        "    value = strlen( json_body ) ) ) ).

        "request->set_text( i_text = CONV #( json_body )
        "                   i_length = strlen( json_body ) ).

        "DATA(response) = http_client->execute( if_web_http_client=>get ).
        "result = response->get_text( ).

        "Broadcast transaction
        DATA(ls_carbon_req_broadcast) = value ty_carbon_req_broadcast( ).
        ls_carbon_req_broadcast-data = ''.
        ls_carbon_req_broadcast-request_id = ''.
        ls_carbon_req_broadcast-signature = ''.
        ls_carbon_req_broadcast-signer = ''.

        "request->set_header_fields( VALUE #(
        "  ( name = 'Content-Type'
        "    value = 'application/json' )
        "  ( name = 'Content-Length'
        "    value = strlen( json_body ) ) ) ).

        "request->set_text( i_text = CONV #( json_body )
        "                   i_length = strlen( json_body ) ).

        "DATA(response) = http_client->execute( if_web_http_client=>get ).
        "result = response->get_text( ).
      CATCH cx_root INTO DATA(lx_exception).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
