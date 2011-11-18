(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  jQuery(function($) {
    var Reveal;
    Reveal = (function() {
      var defaults = {
        animationSpeed: 300,
      };
      function Reveal(content, options) {
        this.content = content;
        this.settings = $.extend({}, defaults, options);
        this.element = $('.reveal-modal').find('.reveal-modal-content').html(this.content).end();
        if (!this.is_shown) {
          this.show();
        }
      }
      Reveal.prototype.show = function() {
        this.is_shown = true;
        this._backdrop();
        return this._escape();
      };
      Reveal.prototype.close = function() {
        this.is_shown = false;
        this.element.hide();
        this._escape();
        return this._backdrop();
      };
      Reveal.prototype._modal = function() {
        var height, that, width;
        that = this;
        this.element.delegate('a.close-reveal-modal', 'click', function(e) {
          e && e.preventDefault();
          return that.close();
        });
        width = this.element.outerWidth() / 2;
        height = this.element.outerHeight() / 2;
        this.element.css({
          'marginLeft': -width,
          'marginTop': -height
        });
        return this.element.show();
      };
      Reveal.prototype._backdrop = function() {
        var backdrop, that;
        backdrop = $('.reveal-modal-bg');
        that = this;
        this.backdrop = backdrop;
        if (backdrop.length === 0) {
          this.backdrop = $('<div class="reveal-modal-bg" />').appendTo(document.body);
        }
        if (this.is_shown) {
          return this.backdrop.fadeIn(this.settings.animationSpeed / 2, function() {
            return that._modal();
          });
        } else {
          return this.backdrop.fadeOut(this.settings.animationSpeed / 2);
        }
      };
      Reveal.prototype._escape = function() {
        var $body, that;
        that = this;
        $body = $('body');
        if (this.is_shown) {
          return $body.bind('keyup', __bind(function(e) {
            if (e.which === 27) {
              return that.close();
            }
          }, this));
        } else {
          return $body.unbind('keyup');
        }
      };
      return Reveal;
    })();
    $('a[data-reveal-id]').bind('click', function(e) {
      var modal_location;
      e.preventDefault();
      modal_location = $(this).attr('data-reveal-id');
      return $('#' + modal_location).reveal();
    });
    return $.fn.reveal = function(options) {
      return this.each(function() {
        return new Reveal(this, options);
      });
    };
  });
}).call(this);
