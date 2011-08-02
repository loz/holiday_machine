$(document).ready(function() {
    $("#holiday_year_id").change(function() {
        $.ajax({
            type: 'GET',
            data: {holiday_year_id: $(this).val()},
            url: '/user_days/'
        });
    });
});