class AddMissingSettingsOfWidgetAndSkipVerification < ActiveRecord::Migration
  def up
	Setting["feature.user.skip_verification"] = 'true' if Setting["feature.user.skip_verification"].nil?

	Setting['feature.homepage.widgets.feeds.proposals'] = true if Setting['feature.homepage.widgets.feeds.proposals'].nil?
	Setting['feature.homepage.widgets.feeds.debates'] = true if Setting['feature.homepage.widgets.feeds.debates'].nil?
	Setting['feature.homepage.widgets.feeds.processes'] = true if Setting['feature.homepage.widgets.feeds.processes'].nil?
	Setting['feature.allow_attached_documents'] = true if Setting['feature.allow_attached_documents'].nil?

  end

  def down
  end
end
