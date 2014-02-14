App.addChild('Project', _.extend({
  el: '#main_content[data-action="show"][data-controller-name="projects"]',

  events: {
    'click #toggle_warning a' : 'toggleWarning',
    'click a#embed_link' : 'toggleEmbed',
    'click a#recommend_link' : 'toggleRecommend'
  },

  activate: function(){
    this.$warning = this.$('#project_warning_text');
    this.$embed= this.$('#project_embed');
    this.$recommend= this.$('#project_recommend');
    this.route('about');
    this.route('updates');
    this.route('backers');
    this.route('comments');
    this.route('edit');
    this.route('reports');
  },

  toggleWarning: function(){
    this.$warning.slideToggle('slow');
    return false;
  },

  toggleEmbed: function(){
    this.loadEmbed();
    this.$recommend.hide();
    this.$embed.slideToggle('slow');
    return false;
  },

  toggleRecommend: function(){
    this.$embed.hide();
    this.$recommend.slideToggle('slow');
    return false;
  },


  followRoute: function(name){
    var $tab = this.$('nav#project_menu a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ target: $tab });
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.find('.loader').length > 0) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs));
