

class PollsController < ApplicationController
  include PollsHelper

  load_and_authorize_resource
  
  #skip_authorize_resource :only => :op

  has_filters %w{current expired incoming}
  has_orders %w{most_voted newest oldest}, only: [:show, :answer]

  ::Poll::Answer # trigger autoload

  def index
    if (params[:op])
      @polls = @polls.send(@current_filter).op.includes(:geozones).sort_for_list.page(params[:page])
      return render :template => "polls/op"
    else
      @polls = @polls.send(@current_filter).not_op.includes(:geozones).sort_for_list.page(params[:page])
      return  render :template => "polls/index"
    end    
  end

  def op
    @custom_poll_group = true    
    @polls = @polls.send(@current_filter).op.includes(:geozones).sort_for_list.page(params[:page])
  end  

  def finish_op
    @custom_poll_group = true
    return  render :template => "polls/finish_op"
  end  

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @answers_by_question_id = {}         
    
    @questions.each do |question|
      @answers_by_question_id[question.id] = []      
    end
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
    ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id)).each do |answer|      
      @answers_by_question_id[answer.question_id].push(answer.answer)
    end    
    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def answer    
    @questions = @poll.questions.for_render.sort_for_list
    
    @answers_by_question_id = {}     
    @found_error = false
    
    # try to find errors
    @questions.each do |question|      
      if(question.question_answers.count()==0)
        next
      end            
      answers_title = params['answer_question_' + question.id.to_s]  || []
      
      if (@answers_by_question_id[question.id].nil?)
        @answers_by_question_id[question.id] = []
      end      
      if (answers_title.empty?)
        if (!question.allow_many_answers)
          @found_error = true     
        end
      else 
        answers_title.each do | answer_title |
          @answers_by_question_id[question.id].push(answer_title)
        end        
      end
      if !question.qtd_min_answers.nil? && answers_title.size() < question.qtd_min_answers        
        @found_error = true             
      elsif !question.qtd_max_answers.nil? && answers_title.size() > question.qtd_max_answers        
        @found_error = true              
      end
    end
    @token = params[:token]
    unless @found_error
      
      @questions.each do |question|       
        current_answers_title = params['answer_question_' + question.id.to_s] || []
        
        # remove unmarked items
        question.answers.where(:author => current_user).each do |answer|          
          found = false
          current_answers_title.each do |title|
            if answer.answer == title
              found = true
            end
          end
          if !found
            answer.delete
          end
        end

        # add new marked itens
        if current_answers_title
          current_answers_title.each do |title|
            answer = question.answers.find_or_initialize_by(:author => current_user, :answer => title)
            answer.touch if answer.persisted?        
            answer.save!        
            answer.record_voter_participation(@token)            
            question.question_answers.where(question_id: question).each do |question_answer|
              question_answer.set_most_voted
            end            
          end        
        end
      end
      if @poll.op        
        Poll.where(op: true).current.each do |poll|    
          if poll_voter_token(poll, current_user) == '' && poll.id != @poll.id
            return redirect_to poll_path(poll), notice: t("flash.actions.save_changes.notice")            
          end            
        end
        return redirect_to poll_ops_finish_path(), notice: t("flash.actions.save_changes.notice")        
      else
        return redirect_to polls_path(), notice: t("flash.actions.save_changes.notice")
      end
    else
      @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
      @commentable = @poll
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      render :action => 'show'
      return true
    end  
  end

  def stats
    @stats = Poll::Stats.new(@poll).generate
  end

  def results
  end

end
