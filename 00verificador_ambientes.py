import tkinter as tk
from tkinter import ttk
import subprocess
import threading

link_list = [
    "ax-argamedev-3dev.eastus.cloudapp.azure.com",
    "ax-argamevaldev.eastus.cloudapp.azure.com",
    "ax-chiphidev-3dev.eastus.cloudapp.azure.com",
    "ax-criletdev-3dev.eastus.cloudapp.azure.com",
    "ax-domletdev-3dev.eastus.cloudapp.azure.com",
    "ax-domrowdev-3dev.eastus.cloudapp.azure.com",
    "ax-domrowval-3dev.eastus.cloudapp.azure.com",
    "ax-gualetdev-3dev.eastus.cloudapp.azure.com",
    "ax-hndletdev-3dev.eastus.cloudapp.azure.com",
    "ax-nicletdev-3dev.eastus.cloudapp.azure.com",
    "ax-slvletdev-3dev.eastus.cloudapp.azure.com",
    "ax-panletdev-3dev.eastus.cloudapp.azure.com",
    "ax-usamlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-ecumlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-dev2-3dev.eastus.cloudapp.azure.com",
    "ax-dev3-3dev.eastus.cloudapp.azure.com",
    "ax-dev4-3dev.eastus.cloudapp.azure.com",
    "ax-dev5-3dev.eastus.cloudapp.azure.com",
    "ax-dev6-3dev.eastus.cloudapp.azure.com",
    "ax-dev7-3dev.eastus.cloudapp.azure.com",
    "ax-uruicldev-3dev.eastus.cloudapp.azure.com",
    "ax-uruiclgld-3dev.eastus.cloudapp.azure.com",
    "ax-mexmlbdev-3dev.eastus.cloudapp.azure.com",
    "ax-mexmlbgld-3dev.eastus.cloudapp.azure.com"
]

alias_dict = {
    "ax-argamedev-3dev.eastus.cloudapp.azure.com": "ArgAmeDev",
    "ax-argamevaldev.eastus.cloudapp.azure.com": "ArgAmeVal",
    "ax-chiphidev-3dev.eastus.cloudapp.azure.com": "ChiPhiDev",
    "ax-criletdev-3dev.eastus.cloudapp.azure.com": "CriLetDev",
    "ax-domletdev-3dev.eastus.cloudapp.azure.com": "DomLetDev",
    "ax-domrowdev-3dev.eastus.cloudapp.azure.com": "DomRowDev",
    "ax-domrowval-3dev.eastus.cloudapp.azure.com": "DomRowVal",
    "ax-gualetdev-3dev.eastus.cloudapp.azure.com": "GuaLetDev",
    "ax-hndletdev-3dev.eastus.cloudapp.azure.com": "HndLetDev",
    "ax-nicletdev-3dev.eastus.cloudapp.azure.com": "NicLetDev",
    "ax-slvletdev-3dev.eastus.cloudapp.azure.com": "SlvLetDev",
    "ax-panletdev-3dev.eastus.cloudapp.azure.com": "PanLetDev",
    "ax-usamlbdev-2dev.eastus.cloudapp.azure.com": "UsaMlbDev",
    "ax-ecumlbdev-2dev.eastus.cloudapp.azure.com": "EcuMlbDev",
    "ax-dev2-3dev.eastus.cloudapp.azure.com": "Dev2", 
    "ax-dev3-3dev.eastus.cloudapp.azure.com": "Dev3",
    "ax-dev4-3dev.eastus.cloudapp.azure.com": "Dev4",
    "ax-dev5-3dev.eastus.cloudapp.azure.com": "Dev5",
    "ax-dev6-3dev.eastus.cloudapp.azure.com": "Dev6",
    "ax-dev7-3dev.eastus.cloudapp.azure.com": "Dev7",
    "ax-uruicldev-3dev.eastus.cloudapp.azure.com": "UruIclDev",
    "ax-uruiclgld-3dev.eastus.cloudapp.azure.com": "UruIclGld",
    "ax-mexmlbdev-3dev.eastus.cloudapp.azure.com": "MexMlbDev",
    "ax-mexmlbgld-3dev.eastus.cloudapp.azure.com": "MexMlbGld"
}

detener = False
no_respondieron_list = []

def verificar_links():
    global detener, no_respondieron_list
    detener = False
    resultado_text.config(state="normal")
    resultado_text.delete(1.0, tk.END)
    lista_no_respondieron.delete(0, tk.END)
    no_respondieron_list = []  # 🧹 Limpiar también la lista interna

    total = len(link_list)
    respondieron = 0
    no_respondieron = 0
    no_respondieron_list = []

    barra_progreso["maximum"] = total
    barra_progreso["value"] = 0
    porcentaje_var.set(0)

    boton_verificar.config(state=tk.DISABLED)
    boton_detener.config(state=tk.NORMAL)

    for idx, link in enumerate(link_list):
        if detener:
            resultado_text.insert(tk.END, "\n⛔ Verificación detenida por el usuario.\n", "warning")
            break

        alias = alias_dict.get(link, link)
        resultado_text.insert(tk.END, f"🔎 Verificando: {alias} ({link})\n", "info")
        resultado_text.update_idletasks()

        result = subprocess.run(["ping", "-n", "2", link], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if result.returncode != 0:
            resultado_text.insert(tk.END, f"❌ {alias} no responde al ping\n\n", "error")
            no_respondieron += 1
            no_respondieron_list.append((link, alias))
        else:
            resultado_text.insert(tk.END, f"✅ {alias} responde correctamente\n\n", "ok")
            respondieron += 1

        barra_progreso["value"] = idx + 1
        porcentaje = int((barra_progreso["value"] / total) * 100)
        porcentaje_var.set(f"{porcentaje}%")
        resultado_text.update_idletasks()

    if not detener:
        resultado_text.insert(tk.END, "─" * 80 + "\n", "divider")
        resultado_text.insert(tk.END, f"📋 Total de ambientes: {total}\n", "info")
        resultado_text.insert(tk.END, f"✅ Respondieron: {respondieron}\n", "ok")
        resultado_text.insert(tk.END, f"❌ No respondieron: {no_respondieron}\n", "error")

        if no_respondieron > 0:
            resultado_text.insert(tk.END, "🔴 Algunos ambientes no responden. Revisar.\n", "error")
            mostrar_no_respondieron()
        else:
            resultado_text.insert(tk.END, "🟢 Todos los ambientes están online.\n", "ok")

    resultado_text.config(state="disabled")
    boton_verificar.config(state=tk.NORMAL)
    boton_detener.config(state=tk.DISABLED)

def iniciar_verificacion():
    thread = threading.Thread(target=verificar_links)
    thread.start()

def detener_verificacion():
    global detener
    detener = True

def verificar_ambiente_seleccionado():
    seleccion = lista_no_respondieron.curselection()
    if seleccion:
        item = lista_no_respondieron.get(seleccion)
        ambiente = item[item.find("(")+1:item.find(")")]  # Extrae el hostname

        alias = alias_dict.get(ambiente, ambiente)
        resultado_text.config(state="normal")
        resultado_text.insert(tk.END, f"🔎 Volviendo a verificar: {alias} ({ambiente})\n", "info")
        resultado_text.update_idletasks()

        result = subprocess.run(["ping", "-n", "2", ambiente], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if result.returncode != 0:
            resultado_text.insert(tk.END, f"❌ {alias} sigue sin responder al ping\n\n", "error")
        else:
            resultado_text.insert(tk.END, f"✅ {alias} ahora responde correctamente\n\n", "ok")

        resultado_text.config(state="disabled")

def mostrar_no_respondieron():
    for link, alias in no_respondieron_list:
        lista_no_respondieron.insert(tk.END, f"{alias} ({link})")

def habilitar_boton(event):
    if lista_no_respondieron.curselection():
        boton_verificar_seleccionado.config(state=tk.NORMAL)
    else:
        boton_verificar_seleccionado.config(state=tk.DISABLED)

# Interfaz
ventana = tk.Tk()
ventana.title("Verificador de Ambientes")
ventana.state("zoomed")
ventana.configure(bg="#1e1e1e")

# Estilo scrollbar
style = ttk.Style()
style.theme_use("clam")
style.configure("Vertical.TScrollbar",
                gripcount=0,
                background="#3a3a3a",
                troughcolor="#2d2d2d",
                bordercolor="#2d2d2d",
                arrowcolor="white",
                relief="flat")

main_frame = tk.Frame(ventana, bg="#1e1e1e")
main_frame.pack(expand=True, fill="both", padx=20, pady=20)

left_frame = tk.Frame(main_frame, bg="#1e1e1e")
left_frame.pack(side="left", expand=True, fill="both", padx=10)

text_frame = tk.Frame(left_frame, bg="#1e1e1e")
text_frame.pack(expand=True, fill="both", padx=20, pady=20)

resultado_text = tk.Text(
    text_frame, wrap=tk.WORD, font=("Segoe UI", 11),
    bg="#2d2d2d", fg="white", insertbackground="white",
    borderwidth=0, relief=tk.FLAT
)
resultado_text.pack(side="left", fill="both", expand=True)

scrollbar = ttk.Scrollbar(text_frame, orient="vertical", command=resultado_text.yview, style="Vertical.TScrollbar")
scrollbar.pack(side="right", fill="y")
resultado_text.config(yscrollcommand=scrollbar.set)

resultado_text.tag_config("error", foreground="#ff6b6b", font=("Segoe UI", 11, "bold"))
resultado_text.tag_config("ok", foreground="#51fa7c")
resultado_text.tag_config("info", foreground="#6cb4ff")
resultado_text.tag_config("warning", foreground="#ffa500")
resultado_text.tag_config("divider", foreground="#888888")

barra_frame = tk.Frame(left_frame, bg="#1e1e1e", padx=5, pady=5)
barra_frame.pack(fill="x", padx=10, pady=10)

barra_progreso = ttk.Progressbar(barra_frame, orient="horizontal", length=200, mode="determinate", style="TProgressbar")
barra_progreso.pack(pady=5, side="left", fill="x", expand=True)

porcentaje_var = tk.StringVar()
porcentaje_label = tk.Label(barra_frame, textvariable=porcentaje_var, font=("Segoe UI", 11), bg="#1e1e1e", fg="white")
porcentaje_label.pack(side="right", padx=10)

boton_frame = tk.Frame(left_frame, bg="#1e1e1e", pady=5)
boton_frame.pack(pady=5)

estilo_boton = {"font": ("Segoe UI", 11, "bold"), "bg": "#444", "fg": "white", "activebackground": "#666", "activeforeground": "white", "bd": 0, "padx": 10, "pady": 5}

boton_verificar = tk.Button(boton_frame, text="▶ Iniciar Verificación", command=iniciar_verificacion, **estilo_boton)
boton_verificar.grid(row=0, column=0, padx=10)

boton_detener = tk.Button(boton_frame, text="⏹ Detener", command=detener_verificacion, state=tk.DISABLED, **estilo_boton)
boton_detener.grid(row=0, column=1, padx=10)

right_frame = tk.Frame(main_frame, bg="#1e1e1e", padx=10, pady=10)
right_frame.pack(side="right", fill="y", expand=True)

lista_frame = tk.Frame(right_frame, bg="#1e1e1e", padx=10, pady=10)
lista_frame.pack(pady=10, fill="x")

lista_no_respondieron_label = tk.Label(lista_frame, text="Ambientes que no respondieron:", font=("Segoe UI", 11), bg="#1e1e1e", fg="white")
lista_no_respondieron_label.pack()

lista_no_respondieron = tk.Listbox(lista_frame, width=50, height=10, font=("Segoe UI", 10), bg="#2d2d2d", fg="white", selectbackground="#3a3a3a", selectforeground="white")
lista_no_respondieron.pack(padx=5, pady=5)

boton_verificar_seleccionado = tk.Button(lista_frame, text="▶ Verificar Seleccionado", command=verificar_ambiente_seleccionado, state=tk.DISABLED, **estilo_boton)
boton_verificar_seleccionado.pack(pady=5)

ventana.bind("<Escape>", lambda e: ventana.destroy())
ventana.bind("<<ListboxSelect>>", habilitar_boton)

ventana.mainloop()
