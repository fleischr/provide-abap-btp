CLASS zcl_prvd_vet_sample DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    types: begin of ty_prvd_ident_basicauth,
                email type string,
                password type string,
           end of ty_prvd_ident_basicauth,
           begin of ty_prvd_sessionaccesstoken,
                user_id type string,
                organization_id type string,
           end of ty_prvd_sessionaccesstoken.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prvd_vet_sample IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    try.
        "Provide APIs
        data(lo_prvdbtp_ident) = cl_http_destination_provider=>create_by_url( 'https://ident.provide.technology' ).
        data(lo_prvdbtp_vault) = cl_http_destination_provider=>create_by_url( 'https://vault.provide.technology' ).
        "Vechain Thor REST APIs
        data(lo_vechain_thor_destination) = cl_http_destination_provider=>create_by_url( 'https://node-testnet.vechain.energy' ).
        data(lo_vechain_sponsor_destination) = cl_http_destination_provider=>create_by_url( 'https://sponsor-testnet.vechain.energy' ).
    catch cx_root INTO DATA(lx_exception).
      out->write( lx_exception->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
