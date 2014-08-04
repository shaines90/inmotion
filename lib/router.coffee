Router.configure
  layoutTemplate: 'plain_layout'

Router.map ->
  @route 'main',
    path: '/'
    layoutTemplate: 'map_layout'

  @route 'login'
  @route 'registration'
  @route 'forgotPassword'


