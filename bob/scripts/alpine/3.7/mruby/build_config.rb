MRuby::Build.new do |conf|

    toolchain :gcc

    conf.gembox 'full-core'

    #
    # Example:
    # Pull in requirements for the application
    #
    # conf.gem :github => 'yokogawa-k/mruby-webapi', :branch => 'support_unix_domain_socket'
end
