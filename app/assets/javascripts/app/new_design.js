  (function($) {
    


  $(document).ready(function(){ 
    
    setTimeout(function() { $('.notice').hide(); }, 6000);
    setTimeout(function() { $('.error').hide(); }, 5000);

    $("#clear-user").click(function () {
      $("input:not(#user_password, #export-user, #export_date)").val(""); 
      $('.error').hide();
    });

    $('.top-right .desktop-search').click(function () {
      $(".desktop-search-form").toggle(); 
      $(".ask-an-adviser ").toggle();
    });

    $('#main-menu li').hover(
      function(){ $(this).addClass('open') },
      function(){ $(this).removeClass('open') }
		)

    $('.navbar-collapse').not('#main-menu').click(function() {
      $('#main-menu li').removeClass('open');
    });

  });    

        

   $(window).scroll(function() {
		if ($(this).scrollTop() > 44){  
		    $('.newHeader').addClass("fixed");
        $('#toolbar').addClass("tbarfix");
		  }
		  else{
		    $('.newHeader').removeClass("fixed");
        $('#toolbar').removeClass("tbarfix");
		  }
	});

   $("form").submit(function(e){
      var count = 0;

      $('.check1').each(function(){
        $(this).find(".chk-required").each(function(){
          if($(this).is(":checked"))
          {
            console.log("in");
            count++;
            return false;
          }
          else
          {
          
             flag = false;
          }
        })
        
      });
      if(count < $('.check1').length )
      {
        alert ( "ERROR! Please select at least one checkbox for required questions." );
          e.preventDefault(e);
      }

    });


})(jQuery);
