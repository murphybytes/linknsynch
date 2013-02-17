// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_tree .

SITENAME = {
    common: {
	init: function() {
	    
	}
    },

    calculations: {
	create: function() {
	    
	}
    }
};

UTIL = {
    exec: function( controller, action ) {
	var ns = SITENAME, action = ( action === undefined ) ? "init" : action ;
	if( controller !== "" && ns[controller] && typeof ns[controller][action] == "function" ) {
	    ns[controller][action]();
	}
    },

    init: function() {
	var body = document.body, 
	controller = body.getAttribute('data-controller'),
	action = body.getAttribute( 'data-action' );

	UTIL.exec( "common" );
	UTIL.exec( controller );
	UTIL.exec( controller, action ) ;
    }
};

$( document ).ready( UTIL.init );