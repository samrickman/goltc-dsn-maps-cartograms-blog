
    // hide the floating sidebar on load as it sits over the map
    // when page first loads
    window.onload = function() {
    let sidebar = document.getElementsByClassName("quarto-sidebar-toggle")[0];
    sidebar.style.display = "none";


        
    
};

document.addEventListener("DOMContentLoaded", (event) => {
  console.log("DOM fully loaded and parsed");

    // quick temp hack for color of titles because of 
    // css clash - fix later
    //let text = document.querySelectorAll('h1,h2,.subtitle,p,.quarto-title-meta-heading,.quarto-title-meta-contents,.csl-entry,.quarto-categories,.quarto-category');
    let text = document.querySelectorAll('.title,.subtitle,.quarto-categories,.quarto-category');
    for(let i = 0; i < text.length; i++) {
        text[i].style.color = "#01457a";
    }

});

    // make sure it doesn't come back when you scroll up
    document.addEventListener("scroll", (event) => {

    let sidebars = document.getElementsByClassName("quarto-sidebar-toggle");

    // No sidebar no problem
    if(sidebars.length===0) {
        return
    }

    sidebars[0].style.display = "none";
    
    });


