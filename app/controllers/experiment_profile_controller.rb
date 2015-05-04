class ExperimentProfileController < ApplicationController

  before_filter :require_login

  # returns experiment profile
  def show
    @profile = deter_lab.get_experiment_profile(params[:id])
    render 'shared/profile'
  end

  # shows the profile edit form
  def edit
    @profile_description = deter_lab.get_experiment_profile_description
    @profile = deter_lab.get_experiment_profile(params[:experiment_id])
  end

end
