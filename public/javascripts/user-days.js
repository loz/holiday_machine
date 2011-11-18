$(document).ready(function() {
  $("#holiday_year_id").change(function() {
    $.ajax({
      type: 'GET',
      data: { holiday_year_id: $(this).val() },
      url: '/user_days/'
    });
  });

  $('table').delegate('a', 'click', function(e) {
    e && e.preventDefault();
    var $el = $(this);
    if (!$el.hasClass('user-days-dialog')) return;
    $('#' + $el.attr('data-dialog')).reveal();
  });
}); 
