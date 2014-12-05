class CommentsController < ApplicationController
  include ActionController::Live

  def new
    @comment = Comment.new
    @comments = Comment.order('created_at DESC')
    binding.pry
    response.headers['X-Content-Type-Options'] = 'text/event-stream'
    sse = SSE.new(response.stream)
    begin
      Comment.on_change do |id|
        comment = Comment.find(id)
        t = render_to_string(partial: 'comment', formats: [:html], locals: {comment: comment})
        sse.write(t)
      end
    end
    rescue IOError
      # Client Disconnected
    ensure
      sse.close
    end
    render nothing: true
  end

  def index

  end

  # def create
  #   respond_to do |format|
  #     if current_user
  #       @comment = current_user.comments.build(comment_params)
  #       if @comment.save
  #         flash.now[:success] = 'Your comment was successfully posted!'
  #       else
  #         flash.now[:error] = 'Your comment cannot be saved.'
  #       end
  #       format.html {redirect_to root_url}
  #       format.js
  #     else
  #       format.html {redirect_to root_url}
  #       format.js {render nothing: true}
  #     end
  #   end
  # end

  def create
    if current_user
      @comment = current_user.comments.build(comment_params)
      @comment.save
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end