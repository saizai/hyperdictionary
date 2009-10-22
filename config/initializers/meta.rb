APP_NAME = 'Kura2'
if RAILS_ENV == 'development'
  APP_HOST = 'localhost:3000'
else
  APP_HOST = 'dictionary.conlang.org'
end
ADMIN_EMAIL = 'kura2-admin@conlang.org'