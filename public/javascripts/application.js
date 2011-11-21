// Place your application-specific JavaScript functions and classes here

$(document).ready(function() {

    // Flash messages
    $('#flash').delegate('a.close', 'click', function(e) {
      e && e.preventDefault();
      $(this).parent().fadeOut('fast');
    });

    // Datepicker
    var datepicker_defaults = {
        dateFormat: 'dd/mm/yy',
        changeMonth: true,
        changeYear: true,
        firstDay: 1,
        beforeShowDay: $.datepicker.noWeekends
    };
    $.datepicker.setDefaults(datepicker_defaults);

    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();

    $('#calendar').fullCalendar({
        header: {
          left: 'prev,next today',
          center: 'title',
          right: false
        },
        eventClick: function(calEvent, jsEvent, view) {
          window.location = "/vacations/" + calEvent.id
        },
        theme: true,
        events: "/calendar",
        disableDragging: true,
        weekends: false
    });

    $('#vacation_date_from, #vacation_date_to').datepicker();

    $("#vacation_date_from").change(function(){
        if ($("#vacation_date_to").val() < $("#vacation_date_from").val()){
          $("#vacation_date_to").val($("#vacation_date_from").val());
        }
    });

    $('a.delete').live('click', function(event) {

        if (confirm("Are you sure you want to delete these days?"))
            $.ajax({
                url: this.href.replace('/destroy', ''),
                type: 'post',
                dataType: 'script',
                data: { '_method': 'destroy' },
                success: function() {
                    alert("Success");
                },
                failure: function() {
                    alert("failed");
                }
            });

        return false;
    });

    $('#closeButton').click(function() {
        $("#error_panel").hide('slide', {direction: 'right'}, 1000);
    });

});

(function($) {
  $.fn.resetForm = function() {
    this.each(function(){
      $(this)[0].reset();
    });
  }
})(jQuery);
