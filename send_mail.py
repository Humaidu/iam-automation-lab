import sys
import os
import smtplib
from email.mime.text import MIMEText
from dotenv import load_dotenv

load_dotenv()
def send_email(to_email, subject, body):
    from_email =os.getenv("email")
    password = os.getenv("app_password")
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = from_email
    msg['To'] = to_email

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
        server.login(from_email, password)
        server.send_message(msg)

if __name__ == "__main__":
    send_email(sys.argv[1], sys.argv[2], sys.argv[3])
