// This file is compiled by Vite along with any other files
// present in this directory.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "../channels"
import $ from "jquery"
window.$ = window.$ || $
window.jQuery = window.jQuery || $
import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap

// Styles
import "../stylesheets/application.scss"

Rails.start()
ActiveStorage.start()
