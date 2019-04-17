class AddAllowManyAnswersToPollQuestions < ActiveRecord::Migration
  def change
    add_column :poll_questions, :allow_many_answers, :boolean
    add_column :poll_questions, :qtd_max_answers, :integer
    add_column :poll_questions, :qtd_min_answers, :integer
  end
end
