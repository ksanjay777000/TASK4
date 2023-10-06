from tkinter import*
from tkinter import ttk
from PIL import Image, ImageTk
from tkinter import messagebox
import mysql.connector
from twilio.rest import Client
import random
from tkinter import Toplevel, Label
from otp_verifier import otp_verifier


def main():
    win = Tk()
    app = login(win)
    win.mainloop()


class login:
    def __init__(self, root):

        self.root = root
        self.root.title("login")
        self.root.geometry("1550x800+0+0")
        self.otp_secret = None
        self.otp_entered = None
        self.verify_btn = None
        self.is_logged_in = False

        self.bg = ImageTk.PhotoImage(file="bglogin1.png")

        lbl_bg = Label(self.root, image=self.bg)
        lbl_bg.place(x=0, y=0, relwidth=1, relheight=1)

        frame = Frame(self.root, bg="white")
        frame.place(x=610, y=170, width=340, height=450)

        img1 = Image.open("login icon.png")
        img1 = img1.resize((100, 100), Image.FILTERED)
        self.photoimage1 = ImageTk.PhotoImage(img1)
        lblimg1 = Label(image=self.photoimage1, bg="black", borderwidth=0)
        lblimg1.place(x=730, y=175, width=100, height=100)
        # label
        username = lbl = Label(frame, text="Username", font=("times new roman", 15, "bold"), fg="black", bg="pink")
        username.place(x=70, y=155)

        self.txtuser = ttk.Entry(frame, font=("times new roman", 15, "bold"))
        self.txtuser.place(x=40, y=180, width=270)

        password = lbl = Label(frame, text="Password", font=("times new roman", 15, "bold"), fg="black", bg="pink")
        password.place(x=70, y=225)

        self.txtpass = ttk.Entry(frame, font=("times new roman", 20, "bold"),show="*")
        self.txtpass.place(x=40, y=250, width=270)

        img2 = Image.open("user12.png")
        img2 = img2.resize((25, 25), Image.FILTERED)
        self.photoimage2 = ImageTk.PhotoImage(img2)
        lblimg2 = Label(image=self.photoimage1, bg="black", borderwidth=0)
        lblimg2.place(x=650, y=323, width=25, height=25)

        img3 = Image.open("ps1.png")
        img3 = img3.resize((100, 100), Image.FILTERED)
        self.photoimage3 = ImageTk.PhotoImage(img1)
        lblimg3 = Label(image=self.photoimage1, bg="black", borderwidth=0)
        lblimg3.place(x=650, y=395, width=25, height=25)

        self.verify_btn = Button(frame, text="Verify OTP", command=self.generate_otp_and_open_verification,
                                 font=("times new roman", 15, "bold"), borderwidth=0, fg="black",
                                 bg="pink", activeforeground="black", activebackground="pink")
        self.verify_btn.place(x=10, y=410, width=160)

        # login button
        loginbtn = Button(frame, text="login", borderwidth=3, relief=RAISED, cursor="hand2", command=self.login,
                          font=("times new roman", 20, "bold"), fg="white", bg="red", activeforeground="white",
                          activebackground="red")
        loginbtn.place(x=110, y=300, width=120, height=35)

        # registerbutton

        registerbtn = Button(frame, text="new user register", command=self.register_window,
                             font=("times new roman", 10, "bold"), borderwidth=0, fg="black", bg="pink",
                             activeforeground="black", activebackground="pink")
        registerbtn.place(x=19, y=350, width=160)

        # forget button
        registerbtn = Button(frame, text="forgot password",
                             font=("times new roman", 10, "bold"), borderwidth=0, fg="black",
                             bg="pink", activeforeground="black", activebackground="pink")
        registerbtn.place(x=10, y=380, width=160)

    def register_window(self):
        self_new_window = Toplevel(self.root)
        self.app = Register(self_new_window)


    
    def open_welcome_page(self):
        welcome_page = WelcomePage(self.root)
        welcome_page.grab_set()

    def generate_otp_and_open_verification(self):
        otp = self.generate_otp()
        self.otp_secret = otp  # Save the OTP secret for later verification
        mobile_number = "+91-7780131283"  # Replace this with the user's mobile number from the registration data

    # Send the OTP to the mobile number using Twilio API
    # Your Twilio Account SID and Auth Token
        account_sid = "your_account_sid"
        auth_token = "your_auth_token"
        client = Client("ACee79e8c555371ffac71a06c0e7eb3425", "d5ca598de471f52e922e7ad99c44104c")

    # Replace "your_twilio_phone_number" with your actual Twilio phone number
        message = client.messages.create(
        body=f"Your OTP is: {otp}",
        from_="+13187502590",
        to="+91-7780131283"
    )

        otp_window = otp_verifier(self.root, otp, mobile_number)
        otp_window.grab_set()
    
    def verify_otp(self, entered_otp):
       if entered_otp == self.otp_secret:
        # Send success response and open welcome page
        messagebox.showinfo("Success", "OTP Verified Successfully!")
        self.open_welcome_page()
       else:
         messagebox.showerror("Error", "Invalid OTP. Please try again.")
    

    

    def login(self):
        if self.txtuser.get() == "" or self.txtpass.get() == "":
            messagebox.showerror("Error", "all fields required")
        elif self.txtuser.get() == "lisa" and self.txtpass.get() == "sanvi":
            messagebox.showinfo("Success", "welcome to page")
            self.is_logged_in = True
            self.enable_verify_button()
            self.generate_otp_and_open_verification()
        else:
            conn = mysql.connector.connect(
                host="127.0.0.1",
                port="3306",
                user="root",
                password="Sravanthi@7",
                database="office"
            )
            my_cursor = conn.cursor()
            my_cursor.execute("SELECT * FROM register WHERE email=%s AND password=%s", (
                self.txtuser.get(), self.txtpass.get())
                              )

            row = my_cursor.fetchone()
            if row is None:
                messagebox.showerror("Error", "Invalid Username & Password")
            else:
                open_main=messagebox.askyesno("YesNo","Access only admin)")
                if open_main>0:
                    self.new_window=Toplevel(self.new_window)
                    self.app=otp_verifier(self.new_window)
                else:
                    if not open_main:
                        return

            conn.commit()
            conn.close()

    def enable_verify_button(self):
        if self.verify_btn is not None:
            self.verify_btn.config(state=NORMAL)

    @staticmethod
    def generate_otp():
        return str(random.randint(1000, 9999))
    
    

class otp_verifier(Toplevel):
    def __init__(self, root, otp, mobile_number):
        super().__init__(root)
        self.geometry("400x200+400+200")
        self.title("Verify OTP")
        self.otp = otp
        self.entered_otp = StringVar()
        self.mobile_number = mobile_number
        self.create_widgets()

    def create_widgets(self):
        lbl_otp = Label(self, text="Enter OTP:", font=("Helvetica", 12))
        lbl_otp.pack(pady=10)

        entry_otp = Entry(self, textvariable=self.entered_otp, font=("Helvetica", 12))
        entry_otp.pack(pady=5)

        btn_verify = Button(self, text="Verify", command=self.verify_otp, font=("Helvetica", 12))
        btn_verify.pack(pady=10)

        img2 = Image.open("user12.png")
        img2 = img2.resize((25, 25), Image.FILTERED)
        self.photoimage2 = ImageTk.PhotoImage(img2)
        lblimg2 = Label(self, image=self.photoimage2, bg="black", borderwidth=0)
        lblimg2.pack(padx=5, pady=5)

        img3 = Image.open("ps1.png")
        img3 = img3.resize((25, 25), Image.FILTERED)
        self.photoimage3 = ImageTk.PhotoImage(img3)
        lblimg3 = Label(self, image=self.photoimage3, bg="black", borderwidth=0)
        lblimg3.pack(padx=5, pady=5)

    def verify_otp(self):
        entered_otp = self.entered_otp.get()
        if entered_otp == self.otp:
            messagebox.showinfo("Success", "OTP Verified Successfully!")
            welcome_page = WelcomePage(self.master)
            welcome_page.grab_set()
            self.destroy()
        else:
            messagebox.showerror("Error", "Invalid OTP. Please try again.")

       
#register form

class Register:
    def __init__(self,root):
        self.root=root
        self.root.title("Register")
        self.root.geometry("1600x900+0+0")

        #variables
        self.var_fname=StringVar()
        self.var_lname=StringVar()
        self.var_contact=StringVar()
        self.var_email=StringVar()
        self.var_securityQ=StringVar()
        self.var_securityA=StringVar()
        self.var_pass=StringVar()
        self.var_confpass=StringVar()

        #bg image
        self.bg=ImageTk.PhotoImage(file="bgregister1.png")
        bg_lbl=Label(self.root,image=self.bg)
        bg_lbl.place(x=0,y=0,relwidth=1,relheight=1)

        #left image
        self.bg1=ImageTk.PhotoImage(file="bg2register.png")
        left_lbl=Label(self.root,image=self.bg1)
        left_lbl.place(x=50,y=100,width=470,height=550)

        frame=Frame(self.root,bg="white")
        frame.place(x=520,y=100,width=800,height=550)

        register_lbl=Label(frame,text="REGISTER HERE",font=("times new romen",15,"bold"),fg="darkgreen",bg="white")
        register_lbl.place(x=20,y=20)

        #label and entry
        #row1
        fname=Label(frame,text="First Name",font=("times new roman",15,"bold"),bg="white")
        fname.place(x=50,y=100)

        self.fname_entry=ttk.Entry(frame,textvariable=self.var_fname,font=("times new roman",15,"bold"))
        self.fname_entry.place(x=50,y=130,width=250)

        l_name=Label(frame,text="Last Name",font=("times new roman",15,"bold"),bg="white",fg="black")
        l_name.place(x=370,y=100)

        self.txt_lname=ttk.Entry(frame,textvariable=self.var_lname,font=("times new roman",15))
        self.txt_lname.place(x=370,y=130,width=250)

       

        #row2
        Contact=Label(frame,text="Contact No",font=("times new romen",15,"bold"),bg="white")
        Contact.place(x=50,y=170)

        self.Contact_entry=ttk.Entry(frame,textvariable=self.var_contact,font=("times new roman",15,"bold"))
        self.Contact_entry.place(x=50,y=200,width=250)

        email=Label(frame,text="Email",font=("times new roman",15,"bold"),bg="white",fg="black")
        email.place(x=370,y=170)

        self.txt_email=ttk.Entry(frame,textvariable=self.var_email,font=("times new roman",15))
        self.txt_email.place(x=370,y=200,width=250)

        #row3

        security_Q=Label(frame,text="Security Answer",font=("times new romen",15,"bold"),fg="black",bg="white")
        security_Q.place(x=50,y=240)

        self.combo_security_Q=ttk.Combobox(frame,textvariable=self.var_securityQ,font=("times new roman",15,"bold"),state="readonly")
        self.combo_security_Q["values"]=("Select","Your Birth Place","Your school name","Your Pet Name")
        self.combo_security_Q.place(x=50,y=270,width=250)
        self.combo_security_Q.current(0)

        security_A=Label(frame,text="Security Answer",font=("times new romen",15,"bold"),fg="black",bg="white")
        security_A.place(x=370,y=240)

        self.txt_security=ttk.Entry(frame,textvariable=self.var_securityA,font=("times new roman",20))
        self.txt_security.place(x=370,y=270,width=250)

        #row4

        pswd=Label(frame,text="Password",font=("times new romen",15,"bold"),fg="black",bg="white")
        pswd.place(x=50,y=310)

        self.txt_pswd=ttk.Entry(frame,textvariable=self.var_pass,font=("times new roman",15))
        self.txt_pswd.place(x=50,y=340,width=250)

        confirm_pswd=Label(frame,text="Confirm Password",font=("times new romen",15,"bold"),fg="black",bg="white")
        confirm_pswd.place(x=370,y=310)

        self.txt_confirm_pswd=ttk.Entry(frame,textvariable=self.var_confpass,font=("times new roman",15))
        self.txt_confirm_pswd.place(x=370,y=340,width=250)

        

        #check button
        self.var_check=IntVar()
        self.checkbtn=Checkbutton(frame,variable=self.var_check,text="I Agree The Terms & Conditions",font=("times new roman",12,"bold"),onvalue=1,offvalue=0)
        self.checkbtn.place(x=50,y=380)

        #buttons
        img1=Image.open("register button.png")
        img1=img1.resize((200,50),Image.FILTERED)
        self.photoimage=ImageTk.PhotoImage(img1)
        b1=Button(frame,image=self.photoimage,command=self.register_data,borderwidth=0,cursor="hand2",font=("times new roman",15,"bold"),fg="white")
        b1.place(x=20,y=430,width=200)

        img2=Image.open("login icon.png")
        img2=img2.resize((200,50),Image.FILTERED)
        self.photoimage2=ImageTk.PhotoImage(img2)
        b1=Button(frame,image=self.photoimage2,borderwidth=0,cursor="hand2",font=("times new roman",15,"bold"),fg="white")
        b1.place(x=330,y=420,width=200)


    #function declaration

    def register_data(self):
        if self.var_fname.get()=="" or self.var_email.get()=="" or self.var_securityQ.get()=="Select":
            messagebox.showerror("Error","All fields are required")
        elif self.var_pass.get()!=self.var_confpass.get():
            messagebox.showerror("Error","password & confirm password must be same")
        elif self.var_check.get()==0:
            messagebox.showerror("Error","Please agree our terms and conditions")
        else:
            conn = mysql.connector.connect(
    host="127.0.0.1",
    port="3306",
    user="root",
    password="Sravanthi@7",
    database="office"
)
            my_cursor=conn.cursor()
            Query=("SELECT * FROM register WHERE email=%s")
            value=(self.var_email.get(),)
            my_cursor.execute(Query,value)
            row=my_cursor.fetchone()
            if row!=None:
                messagebox.showerror("Error","User already exists,please try another email")
            else:
                my_cursor.execute("insert into register values(%s,%s,%s,%s,%s,%s,%s)",(
                                                                                        self.var_fname.get(),
                                                                                        self.var_lname.get(),
                                                                                        self.var_contact.get(),
                                                                                        self.var_email.get(),
                                                                                        self.var_securityQ.get(),
                                                                                        self.var_securityA.get(),
                                                                                        self.var_pass.get(),
                                                                                        
                                                                                    ))
            conn.commit()
            conn.close()
            messagebox.showinfo("Success","Registerd Successfully")
            self.generate_otp_and_open_verification() 

    
pass


class WelcomePage(Toplevel):
    def __init__(self, root):
        super().__init__(root)
        self.geometry("1600x900+0+0")
        self.title("Welcome to System")
        label = Label(self, text="Welcome to the System!", font=("Helvetica", 16))
        label.pack(pady=20)


if __name__=="__main__":
    main()
