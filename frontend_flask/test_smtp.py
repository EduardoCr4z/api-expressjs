import smtplib

server = smtplib.SMTP("sandbox.smtp.mailtrap.io", 2525)
server.starttls()
server.login("a6d8d3fd454e60", "70ce65ef699dd8")
print("Login exitoso")
server.quit()