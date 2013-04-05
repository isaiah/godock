// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require jquery
//= require jquery_ujs
//= require jquery.ui.autocomplete
//= require jquery.autocomplete.html.js
//= require jquery.form
//= require jquery.scrollTo-1.4.2-min
//= require showdown
//= require shBrushGo
//= require jquery.qtip.min
//= require cd

//= require_tree .
//

$(document).ready(function() {
	$("#main_search").autocomplete({
		source: function(req, add) {
			$.getJSON("/search_autocomplete", req, function(data) {
				var out = []
				$.each(data, function(i, v) {
					var lbl = "<div class=\"ac_search_result\">"
					lbl += "<span class='name'>" + v.name + "</span>"
          if (v.tc == "") {
            lbl += "<span class='ns'>" + v.ns + "</span>"
          } else {
            lbl += "<span class='ns'>" + v.ns + "/<span class='tc'>" + v.tc + "</span></span>"
          }
					lbl += "<br />"
					lbl += "<span class='shortdoc'>" + v.shortdoc + "</span>"
					lbl += "</div>"
					out.push({label: lbl, value: v.name, href: v.href})
				});
				add(out);
			});
		},
		focus: function(event, ui) {
			return false
		},
		select: function(event, ui) {
			window.location.href = ui.item.href
			return false
		},
    position: {
          my: "right: top", at: "right bottom"
    },
    minLength: 2,
    html: true,
		dataType: "json"
	});
});

