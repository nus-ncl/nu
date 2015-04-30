class ExperimentAspectsController < ApplicationController

  before_filter :require_login
  before_filter :load_experiment
  before_filter :require_owner

  # removes the member record
  def destroy
    res = DeterLab.remove_experiment_aspects(current_user_id, @experiment.id, [
      { name: params[:id], type: params[:type] }
    ])

    options = {}
    if res[params[:id]]
      options[:notice] = t(".success")
      deter_lab.invalidate_experiment(@experiment.id)
    else
      options[:alert] = t(".failure")
    end

    redirect_to experiment_path(@experiment.id), options
  end

  private

  def load_experiment
    @experiment = deter_lab.get_experiment(params[:experiment_id])
  end

  def require_owner
    unless @experiment.owner == @app_session.current_user_id
      redirect_to experiment_path(params[:experiment_id]), alert: t("experiment_members.owner_only")
    end
  end

end
