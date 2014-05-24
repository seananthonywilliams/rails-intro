class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Just to display all checkbox ratings options
    @all_ratings = []
    Movie.all.each do |m|
      @all_ratings.push(m.rating)
    end
    @all_ratings.uniq!.sort! { |r1, r2| r1 <=> r2 }
  
    @ratings = Hash.new
    @all_ratings.each do |k|
      # Set every rating to checked initially
      if ! params.has_key?('ratings') && ! session.has_key?(:ratings)
        @ratings[k] = true
      elsif params.has_key?('ratings') # use params hash
        if params['ratings'].keys.include?(k)
          @ratings[k] = true
        else
          @ratings[k] = false
        end
      else # defer to session hash
        if session[:ratings].keys.include?(k)
          @ratings[k] = true
        else
          @ratings[k] = false
        end
      end
    end
    
    # Add in filtering by checked ratings
    ratings_arr = []
    if params.has_key?('ratings')
      ratings_arr = params['ratings'].keys
      session[:ratings] = params['ratings']
    elsif session.has_key?(:ratings)
      ratings_arr = session[:ratings].keys
    else
      ratings_arr = @all_ratings
    end

    # TODO: Refactor this ugly logic.
    # Basically, the params should override the session information
    if (params.has_key?(:sort) && params[:sort] == 'title') \
        || (session.has_key?(:sort) && session[:sort] == 'title')
      if (params.has_key?(:sort) && params[:sort] == 'release_date')
        @movies = Movie.
                  where(rating: ratings_arr).
                  sort { |m1, m2| m1.release_date <=> m2.release_date}
        @sortby = 'release_date' # Aids in CSS cell highlighting
        session[:sort] = 'release_date'
      else
        @movies = Movie.
                  where(rating: ratings_arr).
                  sort { |m1, m2| m1.title <=> m2.title }
        @sortby = 'title' # Aids in CSS cell highlighting
        session[:sort] = 'title'
        end
    elsif (params.has_key?(:sort) && params[:sort] == 'release_date') \
        || (session.has_key?(:sort) && session[:sort] == 'release_date')
      @movies = Movie.
                where(rating: ratings_arr).
                sort { |m1, m2| m1.release_date <=> m2.release_date }
      @sortby = 'release_date' # Aids in CSS cell highlighting
      session[:sort] = 'release_date'
    else
      @movies = Movie.
                where(rating: ratings_arr)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
