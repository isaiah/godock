class MainController < ApplicationController

  layout 'application', :except => ["lib_search", "preview_example"]
  #caches_page :index
  #caches_page :lib
  #caches_page :quick_ref_shortdesc
  #caches_page :quick_ref_vars_only
  #caches_page :libs
  #caches_page :function
  #caches_page :function_short_link


  def index
    # num_recent = 6
    # num_tc = 24
    # @recently_updated = find_recently_updated(7, nil)
    # @top_contributors = []

    # tc_example_versions = Example.find_by_sql("select count(*), example_versions.user_id from example_versions group by user_id order by count(*) desc")[0, num_tc+1]
    # tc_examples = Example.find_by_sql("select count(*), examples.user_id from examples group by user_id order by count(*) desc;")[0, num_tc+1]

    # tc_examples.each do |e|
    #   count = e["count(*)"]
    #   tc_example_versions.each do |v|
    #     if(e.user_id == v.user_id)
    #       count += v["count(*)"]
    #     end
    #   end

    #   user = User.find(e.user_id)
    #   if not user.id == 1
    #     @top_contributors << {:author => user.login, :email => user.email, :score => count} 
    #   end
    # end
    
    # @top_contributors = @top_contributors[0, num_tc]

  end

  def lib
    name = params[:lib]
    version = params[:version]
    
    @library = nil
    
    if version
      @library = Library.find_by_url_friendly_name_and_version(name, version)
    else
      @library = Library.find_by_url_friendly_name_and_current(name, true)
    end
    
    if not @library
      logger.error "Tried to load library #{params[:lib]}"

      render :template => 'public/404.html', :layout => false, :status => 404
    end
  end

  def quick_ref_shortdesc

    @library = Library.find_by_name(params[:lib])

    if @library and @library.name == "overtone"
      @spheres = CCQuickRef.spheres
      render :action => "clojure_core_shortdesc"
    else
      render :template => 'public/404.html', :layout => false, :status => 404
    end
  end

  def quick_ref_vars_only
    @library = Library.find_by_name(params[:lib])

    if @library and @library.name == "overtone"
      @spheres = CCQuickRef.spheres
      render :action => "clojure_core_vars_only"
    else
      render :template => 'public/404.html', :layout => false, :status => 404
    end
  end

  def libs
    @libs = Library.order('name')
  end

  def search
    q = params[:q] || ""

    # for display on page -- 'You search for x'
    @orig_query = q


    res = []
    for i in (0..q.size)
      after = q[i,q.size]
      before = q[0,i]
      res << before + "_" + after
    end
    res << q

    qm = res.clone
    qm = qm.fill("?")
    
    sql = "select * from functions where (name LIKE " + qm.join(" or name LIKE ") + ")
          AND namespace_id = #{Namespace.find_by_name("overtone.core").id} LIMIT 100"

    begin

      @functions = Function.find_by_sql([sql] + res)
      
      #@functions = @functions.sort{|a,b| Levenshtein.distance(q, a.name) <=> Levenshtein.distance(q, b.name)}
      @functions = @functions[0..24]

    rescue
      @functions = []
    end

    if @functions.size <= 0
    # 
    #   #Sphinx specific code
    #   #if not q.match("@library")
    #   #  q += " @library (\"Clojure Core\" | \"Clojure Contrib\")"
    #   #end
    # 
    #   q = "*" + q + "*"
    # 
       @functions = Function.search(q)
    #   
       @functions = @functions[0..24]
    # 
    end

    # @functions = @functions.find_all { |f|
    #   f.library.current
    # }

    if params[:feeling_lucky] and @functions.size > 0
      func = @functions[0]
      redirect_to "/#{func.library}/#{func.ns}/#{CGI::escape(func.name)}"
    end


  end

    def lib_search
      q = params[:q]
      lib = params[:lib]

      res = []
      for i in (0..q.size)
        after = q[i,q.size]
        before = q[0,i]
        res << before + ".*" + after
      end

      qm = res.clone
      qm = qm.fill("?")

      sql = ""
      out = []
      if lib
        sql = "select name, ns from functions where library = ? and (name RLIKE " + qm.join(" or name RLIKE ")  + ")"   
        #      raise sql
        out = Function.find_by_sql([sql, params[:lib]] + res)
      else
        sql = "select name, ns from functions where name RLIKE " + qm.join(" or name RLIKE ")    
        out = Function.find_by_sql([sql] + res)
      end

      #@functions = out.sort{|a,b| Levenshtein.distance(q, a.name) <=> Levenshtein.distance(q, b.name)}
      @functions = out
      render :json => @functions.map{|f| {:name => f[:name], :ns => f[:ns]}}.to_json
    end

    def ns
      
      lib_name = params[:lib]
      version = params[:version]
      ns_name = params[:ns]
      
      @library = nil
      if version
        @library = Library.find_by_url_friendly_name_and_version(lib_name, version)
      else
        @library = Library.find_by_url_friendly_name_and_current(lib_name, true)
      end
      
      @ns = nil
      if @library
        @ns = Namespace.find_by_name_and_library_id(ns_name, @library.id)
      end
      
      if not @ns or not @library
        render :template => 'public/404.html', :layout => false, :status => 404
      end
    end
    
    def function
      lib_url_name = params[:lib]
      version = params[:version]

      ns = params[:ns]
      type_class = params[:type_class]
      function_url_name = params[:function]

      @function = if type_class
                    Function.for_type_class(function_url_name, type_class, ns, lib_url_name, version)
                  else
                    Function.for_namespace(function_url_name, ns, lib_url_name, version)
                  end || not_found
      
      @example = Example.new
      @comment = Comment.new

      if request.post?
        if params[:update_comment]
          @comment = Comment.find(params[:comment_id])
          if @comment and @comment.user_id == current_user.id
            @comment.body = params[:comment][:body]
          end
        else
          @comment = Comment.build_from(@function, current_user.id, params[:comment][:body])
          @comment.title = params[:comment][:title]
          @comment.subject = params[:comment][:subject]
        end

        @comment.save
        redirect_to @function.href
      end

    end

    def type_class
      lib_url_name = params[:lib]
      version = params[:version]

      ns = params[:ns]
      type_class_name = params[:type_class]
      
      if version
        @type_class = TypeClass.includes(:namespace, {:namespace => :library}).where(
          :namespaces => {:name => ns},
          :libraries => {:url_friendly_name => lib_url_name, :version => version},
          :name => type_class_name).first
      else
        @type_class = TypeClass.includes(:namespace, {:namespace => :library}).where(
          :namespaces => {:name => ns},
          :libraries => { :url_friendly_name => lib_url_name, :current => true},
          :name => type_class_name).first
      end
          
      if not @type_class
        logger.error "Couldn't find function id #{params[:id]}"

        render 404
      end
      
      @example = Example.new
      @comment = Comment.new
    end
    
    def function_short_link
      @function = Function.find(params[:id]) rescue nil
      
      if not @function
        logger.error "Couldn't find function id #{params[:id]}"

        render :template => 'public/404.html', :layout => false, :status => 404
      end
      
      version = (params[:version] || @function.version)
      
      if not @function
        logger.error "Couldn't find function id #{params[:id]}"

        render :template => 'public/404.html', :layout => false, :status => 404
      end
      
      redirect_to :controller => 'main',
			            :action => 'function',
			            :lib => @function.namespace.library.url_friendly_name,
			            :version => (@function.namespace.library.current ? nil : @function.namespace.library.version),
			            :ns => @function.namespace.name,
			            :function => @function.url_friendly_name
			            
    end

    def search_autocomplete
      
      q = params[:term]
      q = q.gsub("-", "")
      if not q
        #render :json => []
        q = ""
      end

      q = '"' + q + '*"'
      
      core_current_version = (Library.find_by_name_and_current("gopkg", true).version rescue nil || "1.0.3")
      contrib_current_version = (Library.find_by_name_and_current("Clojure Contrib", true).version rescue nil || "1.0.3")
      
      # @version (\"#{core_current_version}\" | \"#{contrib_current_version}\")

      @functions = Function.quick_search(q)

        @functions.delete(nil)

        if @functions != nil and @functions.size > 0
          
          #@functions.sort!{|a,b| 
          #  Levenshtein.distance(q, a.name) <=> Levenshtein.distance(q, b.name) 
          #}

           
        end
        
        @exact_matches = Function.find_all_by_name(params[:term])
        
        if @exact_matches
          @functions = (@exact_matches + @functions).uniq
        end

        @functions = @functions.find_all { |f|
          f.library.current
        }

        #if @functions.size > 10
        #  @functions = @functions[0, 10]
        #end

        render :json => @functions.map{|f| {:href => f.href, :ns => f.ns.name, :name => f.name, :examples => f.examples.size, :shortdoc => f.shortdoc }}
      end
      
      def examples_style_guide
        
      end

    end







