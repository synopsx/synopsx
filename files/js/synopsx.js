function init(){
  
      $('*[data-load]').each(function(){
       //+'?pattern='+$(this).prop('tagName').toLowerCase()//;
       $(this).load($(this).data('load') );     
      }); 

      
     var menu = $('#navigation-menu');
      var menuToggle = $('#js-mobile-menu');
      var signUp = $('.sign-up');
      $(menuToggle).on('click', function(e) {
        e.preventDefault();
        menu.slideToggle(function(){
          if(menu.is(':hidden')) {
            menu.removeAttr('style');
          }
        });
      });

 
    

          
          $('#horizontal-nav').find('li').each(function() {
              $(this).removeClass('current');
           });
           var path = location.pathname;
           var res = path.split("/"); 
           var menupath = "/"+res[1]+"/"+res[2];
           $('a[href^="'+menupath+'"]').parent('li').addClass('current');
 


};

