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
            if (calEvent.type === 'bank-holiday') return false;
            window.location = "/vacations/" + calEvent.id
        },
        theme: true,
        events: "/calendar",
        disableDragging: true,
        weekends: false
    });

    $('.fc-button-next, .fc-button-prev, .fc-button-today').bind('click', monthNavigation);

    function monthNavigation(e) {
      var currentDate = $('#calendar').fullCalendar('getDate')
        , currentMonth = currentDate.getMonth()
        , currentYear = currentDate.getFullYear()
        , urlString = '/calendar/show?year=' + currentYear + '&month=' + currentMonth

      e.preventDefault();
      history.pushState('', '', urlString);
      $('#calendar').fullCalendar('gotoDate', currentYear, currentMonth);
    }

    var monthParam = getParameterByName('month')
      , yearParam = getParameterByName('year')
      , monthAndYearParam = monthParam && yearParam;

    if (monthAndYearParam) {
      $('#calendar').fullCalendar('gotoDate', yearParam, monthParam);
    }

    $('#absence_date_from, #absence_date_to').datepicker();

    $("#absence_date_from").change(function() {
        if ($("#absence_date_to").val() < $("#absence_date_from").val()) {
            $("#absence_date_to").val($("#absence_date_from").val());
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

//  Opens the menu link in a new browser tab
    $("li.blank_target a").click(function(event) {
        $(this).attr('target', '_blank');
    });

});

(function($) {
    $.fn.resetForm = function() {
        this.each(function() {
            $(this)[0].reset();
        });
    }
})(jQuery);

function getParameterByName(name) {
  var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
  return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
}
