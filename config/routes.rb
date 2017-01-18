NycCollegeLine::Application.routes.draw do

  devise_for :users,
    controllers: {
      confirmations: :confirmations,
      registrations: :registrations,
      passwords: :passwords,
    },
    path_names: {
      password: 'forgot',
      registration: 'register',
      sign_up: 'signup'
    },
    skip: [:sessions]

  match '/ask-an-adviser' => 'guest_questions#redirect'
  match '/blog-user-registration' => "blog_posts#blog_user"
  match '/global-search' => 'search#global_search' , as: 'global_search'
  get 'feed' => 'blog_posts#feed'

  as :user do
    get 'login' => 'sessions#new', as: :new_user_session
    post 'login' => 'sessions#create', as: :user_session
    delete 'signout' => 'sessions#destroy' #API user logout
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
    match 'registrations/success/:step' => 'registrations#success',
      as: :registration_success
  end

  namespace :api, constraints: { format: 'json' } do

    namespace :v1 do
      match 'faq' => 'masters#faq',via: [:get]
      match 'guest-question' => 'masters#ask_an_adviser_guest',via: [:post]
      match 'user-question' => 'masters#ask_an_adviser_user',via: [:post]
      match 'facebook-login' => 'masters#facebook_login',via: [:post]
      match 'about-contact' => 'masters#about_us',via: [:get]
      match 'terms-of-use' => 'masters#terms_policy',via: [:get]
      match 'apply-data' => 'masters#apply_data',via: [:get]
      match 'scholarships' => 'masters#scholarships',via: [:get]
      match 'scholarship-form' => 'masters#scholarship_form',via: [:post]      
      match 'events' => 'masters#events',via: [:get]
      match 'event-show' => 'masters#event_show',via: [:post]
      match 'event-comment' => 'masters#event_comment',via: [:post]
      match  'reply_to_question' => "masters#reply_to_question", via: [:get, :post]    
      match  'get_question' => "masters#get_question", via: [:get, :post]
      match 'get-data-sync' => 'masters#offline_data',via: [:get, :post]

      match "user-profile" => "masters#user_profile", via: [:post]     
      match 'user-scholarships' => "masters#user_scholarships", via: [:post]
      match 'edit-profile' => "masters#edit_profile", via: [:get, :post]
      match 'upload-photo' => "masters#upload_photo", via: [:post]
      match 'user-setting' => "masters#user_setting", via: [:get, :post]
      match 'bookmark-event' => "masters#bookmark_event", via: [:get, :post, :delete]
      match 'bookmark-faq' => "masters#bookmark_faq", via: [:get, :post, :delete]
      
      match 'user-asked-questions' => "masters#user_asked_questions", via: [:post]
      match 'delete-user-account' => "masters#delete_user_account", via: [:post]
    end
    
  end

  #
  # Public folders
  #
  resources :survey_answers
  resources :folders, only: [:index]

  match '/folders/:id/:slug' => 'folders#show', :as => :folder

  namespace 'admissions', as: 'admin' do


    resources :blog_posts do
      get 'confirm_destroy', on: :member
    end
   
    resources :campaign_ppcs  do
      get 'confirm_destroy', on: :member
    end

    resources :tags

    resources :assets, except: [:show,] do
      get 'browse', on: :collection
      get 'confirm_destroy', on: :member
      post 'details', on: :member
      get 'search', on: :collection
    end

    resources :audiences, :events, :faqs, :forums, :glossary_terms,
              :organizations, :phases, :promo_instances, :scholarships,
              :scholarship_submissions,
                :system_avatars, except: [:show,] do
      get 'confirm_destroy', on: :member
    end

    resources :comments, except: [:show, :new, :create,] do
      get 'confirm_destroy', on: :member
    end

    resources :contact_submissions, only: [:index, :show, :destroy]

    resources :contests do
      get 'confirm_destroy', on: :member
    end

    resources :folders, only: [:index, :show, :update]

    resources :folder_recommendations, only: [:index, :show, :destroy], path: 'recommendations'

    resources :galleries, except: [:show,] do
      get 'browse', on: :collection
      get 'confirm_destroy', on: :member
    end

    resources :glossary_imports, only: [:create, :new,]

    resources :pages, except: [:show,] do
      get 'confirm_destroy', on: :member
      post 'update_order', on: :collection
    end

    resources :questions, except: [:show, :new, :create] do
      get 'confirm_destroy', on: :member
    end

    resources :guest_questions, except: [:show, :new, :create] do
      get 'confirm_destroy', on: :member
    end

    resources :referral_codes, only: [:create]

    resources :resource_imports, only: [:create, :new,]

    resources :resources, except: [:show,] do
      get 'confirm_destroy', on: :member
      get 'search', on: :collection
    end

    resources :resource_suggestions, except: [:show, :new, :create,] do
      get 'confirm_destroy', on: :member
    end

    resources :site_settings, only: [:edit, :update,]
    resources :blog_users do
      get 'confirm_destroy', on: :member
      get 'export_csv', on: :collection

    end  

    resources :users, except: [:show,] do
      get 'confirm_destroy', on: :member
      get 'search', on: :collection
      get 'export_partial', on: :collection
      get "blog_users", on: :collection
    end

    resources :survey_templates do
      get 'confirm_destroy', on: :member
      match 'assign_ques', on: :member  
    end

    resources :survey_questions do
      get 'confirm_destroy', on: :member    
    end

    resources :survey_reports, path: "survey-template-report" do
      get 'confirm_destroy', on: :member    
      get 'report', on: :member, path: "template"
      get 'show', on: :member, path: "template-response"
      delete :delete, on: :member
    end


    root to: 'admissions#index'
  end

  namespace 'guest-profile', as: :guest_profile do
    resources :guest_questions, path: 'guest-ask-an-adviser', only: [:new, :create, :show] do
      post 'build', on: :collection
      get 'success', on: :collection
    end
    root to: 'guest_questions#index'
  end

  namespace 'profile', as: :profile do

    resources :advisers, only: [:index, :show]

    resources :contests, only: [:index] do
      resources :referral_emails, only: [:new, :create]
    end

    resources :folder_recommendations, only: [:new, :create]

    resources :folders, except: [:new] do
      resources :folder_emails, only: [:new, :create]

      member do
        get 'clone'
      end

    end

    resources :forum_threads, path: 'forums', only: [:index]

    resources :questions, path: 'ask-an-adviser', only: [:new, :create, :show] do
      get 'success', on: :collection
    end

    resources :resource_suggestions, path: 'suggest-resource',
      only: [:new, :create]

    resources :resources, only: [:index, :new, :create, :edit, :update]

    resources :settings, only: [:index] do
      put :update_avatar, on: :collection
      put :update, on: :collection
      get :confirm_destroy, on: :collection
      delete :destroy, on: :collection
    end
    match 'settings/audience' => 'settings#audience'
    match 'settings/newsletter' => 'settings#newsletter'
    root to: 'folders#index'
  end

  resources :avatars, only: [:create, :destroy]
  resources :comments, only: [:destroy]
  resources :conditions_of_use, path: 'conditions-of-use', only: [:index]

  resources :contact_submissions, path: 'contact-us',
    only: [:index, :new, :create]

  resources :events, only: [:index, :show] do
     resources :bookmarks, only: [:create, :update] do
      match 'move', on: :collection
      match 'toggle', on: :collection
      match 'sort', on: :collection
    end
    resources :comments, only: [:create]
  end
  match 'events/:year/:month/:day' => 'events#date'
  match 'events/:year/:month' => 'events#monthdate'

  resources :faqs, path: 'faq', only: [:index]

  resources :forums, only: [:index, :show] do
    match 'search', on: :collection
    resources :forum_threads, path: 'threads', only: [:index, :show]
  end

  resources :forum_threads, path: 'threads', only: [:new, :create, :destroy] do
    resources :comments, only: [:create]
  end

  resources :glossary, only: [:index]

  match 'newsletter-hooks' => 'newsletter_hooks#index'

  resources :organizations, only: [:show]

  resources :questions, only: [:index] do
    resources :comments, only: [:create]
  end

  resources :guest_questions, only: [:index] do
    resources :comments, only: [:create]
    resources :guest_comments, only: [:create]
  end

  resources :resources, only: [:show] do
    post 'helpful', on: :member
    resources :bookmarks, only: [:create, :update] do
      match 'move', on: :collection
      match 'toggle', on: :collection
      match 'sort', on: :collection
    end
    resources :comments, only: [:create]
  end

  match 'blog/date/:date' => 'blog_posts#by_date', as: :blog_date
  match 'blog/category/:category' => 'blog_posts#by_category', as: :blog_category
  
  resources :blog_posts, only: [:index, :show], path: 'blog' do
    resources :bookmarks, only: [:create, :update] do
      match 'move', on: :collection
      match 'toggle', on: :collection
      match 'sort', on: :collection
    end
    resources :comments, only: [:create]
  end

  resources :scholarships, only: [:index, :show] do
    resources :scholarship_submissions, only: [:create, :show] do
      resources :user_submission_votes, only: [:create, :destroy]
    end
  end

  resources :campaign_ppcs do
    post 'question', on: :member

  end

  resources :survey_templates do 
    get 'template', on: :member
    match 'survey_answer', on: :member
  end
  
  resources :contacts, only: [:new, :create]

  match 'search' => 'search#index', as: :search

  get '*id' => 'application#show', as: :page

  root to: 'home#index'  

 end
