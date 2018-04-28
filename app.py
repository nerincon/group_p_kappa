import tornado.ioloop
import tornado.web
import tornado.log

import os
import bcrypt
import json
import psycopg2


from jinja2 import \
  Environment, PackageLoader, select_autoescape

ENV = Environment(
  loader=PackageLoader('myapp', 'templates'),
  autoescape=select_autoescape(['html', 'xml'])
)

class TemplateHandler(tornado.web.RequestHandler):
  def render_template (self, tpl, context):
    template = ENV.get_template(tpl)
    self.write(template.render(**context))


# class BaseHandler(tornado.web.RequestHandler):

#   def get_login_url(self):
#     return u"/login"

#   def get_current_user(self):
#     user_json = self.get_secure_cookie("user")
#     if user_json:
#       return tornado.escape.json_decode(user_json)
#     else:
#       return None


class LoginHandler(TemplateHandler):
  def get(self, page='login'):
    page = page + '.html'
    self.render_template(page, {})

  def post(self):
    username = self.get_query_argument('username', None)
    password = self.get_query_argument("password", None)
    conn = psycopg2.connect("dbname=Kappa user=postgres")
    cur = conn.cursor()
    cur.execute("SELECT username, password FROM users WHERE username = %s", [username])
    user = row = cur.fetchone()


    if user and user['password'] and bcrypt.hashpw(password, user['password']) == user['password']:
      self.set_current_user(username)
      self.render_template('hello.html', {})
    else:
      error_msg = u"?error=" + tornado.escape.url_escape("Login incorrect.")
      self.render_template(u"/login" + error_msg)

    cur.close()
    conn.close()

  def set_current_user(self, user):
    print("setting "+user)
    if user:
      self.set_secure_cookie("user", tornado.escape.json_encode(user))
    else:
      self.clear_cookie("user")


class RegisterHandler(LoginHandler):
  def get(self, page='register'):
    page = page + '.html'
    self.render_template(page, {})

  def post(self):
    username = self.get_query_argument('username', None)
    role = self.get_query_argument('role', None)
    conn = psycopg2.connect("dbname=Kappa user=postgres")
    cur = conn.cursor()
    cur.execute("SELECT username, password FROM users WHERE username = %s", [username])
    already_taken = cur.fetchone()
    if already_taken:
      error_msg = u"?error=" + tornado.escape.url_escape("Login name already taken")
      self.redirect(u"/login" + error_msg)
    else:
      password = self.get_query_argument("password", None)
      hashed_pass = bcrypt.hashpw(password, bcrypt.gensalt(10))
      cur.execute("INSERT INTO users VALUES (%s, %s, %s)",(username, password, role))
      conn.commit()
      success_msg = u"?success=" + tornado.escape.url_escape("Registered User Successfully")
      self.redirect(u"/register" + success_msg)
      cur.close()
      conn.close()

def make_app():
  return tornado.web.Application([
    (r"/(login)", LoginHandler),
    (r"/hello", LoginHandler),
    (r"/(register)", RegisterHandler),
    (
      r"/static/(.*)",
      tornado.web.StaticFileHandler,
      {'path': 'static'}
    ),
  ], autoreload=True)



if __name__ == "__main__":
  tornado.log.enable_pretty_logging()
  
  app = make_app()
  PORT = int(os.environ.get('PORT', '8000'))
  app.listen(PORT)
  tornado.ioloop.IOLoop.current().start()


