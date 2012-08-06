module ReportsHelper

	def user_holidays_taken user
		Absence.user_holidays(user.id).per_holiday_year(@current_year_id)
			.where(:holiday_status_id => 4, :absence_type_id => 1).sum(:working_days_used)
	end

	def user_holidays_pending user
		Absence.user_holidays(user.id).per_holiday_year(@current_year_id)
			.where(:holiday_status_id => 1, :absence_type_id => 1).sum(:working_days_used)
	end

	def user_holidays_authorised user
		Absence.user_holidays(user.id).per_holiday_year(@current_year_id)
			.where(:holiday_status_id => 2, :absence_type_id => 1).sum(:working_days_used)
	end

	def user_holidays_unbooked user
		user.get_holiday_allowance.days_remaining
	end

end