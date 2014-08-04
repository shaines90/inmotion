Router.configure
  layoutTemplate: 'plain_layout'

Router.map ->
  @route 'main',
    path: '/'
    layoutTemplate: 'map_layout'
  @route 'map'
  @route 'login'
  @route 'registration'
  @route 'forgotPassword'


