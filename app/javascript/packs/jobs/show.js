$('#add_datum_submit').on('click', function(e) {
    e.preventDefault();

    var sales_price =  $('#add_datum_sales_price');
    var ctp =  $('#add_datum_ctp');
    var pod =  $('#add_datum_pod');
    var kako =  $('#add_datum_kako');
    var out_cost =  $('#add_datum_out_cost');
    var delivery =  $('#add_datum_delivery');
    var assembly =  $('#add_datum_assembly');
    var iroko_num =  $('#add_datum_iroko_num');
    var vprice =  $('#add_datum_vprice');

    sales_price.val(sales_price.val().replace(",",""));
    ctp.val(ctp.val().replace(",",""));
    pod.val(pod.val().replace(",",""));
    kako.val(kako.val().replace(",",""));
    out_cost.val(out_cost.val().replace(",",""));
    delivery.val(delivery.val().replace(",",""));
    assembly.val(assembly.val().replace(",",""));
    iroko_num.val(iroko_num.val().replace(",",""));
    vprice.val(vprice.val().replace(",",""));

    $("#add_datum_form").submit();
});