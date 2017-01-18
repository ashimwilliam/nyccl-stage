$(window).load(function(){

  jQuery('.newpopup #ajax_recaptcha').addClass("newpopuprecaptcha");
  jQuery('.newpopuprecaptcha .recaptchatable').addClass("newpopuprecaptchatable");
  jQuery('.newpopuprecaptcha .recaptcha_image_cell').addClass("newpopuprecaptchaimg");
  
  
  $("#foot-wrap").css("z-index", "1");

  if (!sessionStorage.alreadyClicked) {
    $("#aaa-popup-fade1").addClass("aaa-popup");
    $('body').addClass("popopen"); 
    $('#slider').removeClass('slide');
  }     
    
  $('#signup-close,#aaa-popup-fade1').click(function(){
    $('.custom-modal-signup,#aaa-popup-fade1,.aaa-popup').hide();
    $('body').removeClass("popopen");
    $('#slider').addClass("slide");
    sessionStorage.alreadyClicked = "true"
    setTimeout(function() { $("#aaa-popup-fade2").addClass("aaa-popup");} , 7000 );
    setTimeout(function() { $('body').addClass("popopen");}, 7000); 
    setTimeout(function() { $('#slider').removeClass('slide');}, 7000);
  });  
  

  if (sessionStorage.alreadyClicked == "true" && !sessionStorage.alreadyViewed)  {
    setTimeout(function() { $("#aaa-popup-fade2").addClass("aaa-popup");} , 7000 );
    setTimeout(function() { $('body').addClass("popopen");}, 7000); 
    setTimeout(function() { $('#slider').removeClass('slide');}, 7000);
  }   
    
  $('#aaa-close,#aaa-popup-fade2').click(function(){
    $('.custom-modal-dialog,#aaa-popup-fade2,.aaa-popup').hide();
    $('body').removeClass("popopen");
    $('#slider').addClass("slide");
    sessionStorage.alreadyViewed = "true"
  });

  $('.custom-modal-signup').click(function(event){
    event.stopPropagation();  
  });

  $('.custom-modal-dialog').click(function(event){
    event.stopPropagation();  
  });

   // sign up hide on sign in click
  $('div.already a').click(function() {
    sessionStorage.alreadyClicked = "true";
  });

  // hide both popups on terms and condition page 
  $('p.tos a').click(function() {
    sessionStorage.alreadyClicked = "true";
    sessionStorage.alreadyViewed = "true";
  });

  // hide signup popup on form sunmit 
  $("#signup-popup").submit(function(){
    sessionStorage.alreadyClicked = "true";
  });

    // hide ask an adviser popup on form sunmit 
  $("#aaa-popup").submit(function(){
    sessionStorage.alreadyViewed = "true";
  });


});