import tkinter as tk
from tkinter import scrolledtext
import subprocess

# Lista de enlaces a verificar
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
    "ax-dev2-3dev.eastus.cloudapp.azure.com",
    "ax-dev3-3dev.eastus.cloudapp.azure.com",
    "ax-dev4-3dev.eastus.cloudapp.azure.com",
    "ax-dev5-3dev.eastus.cloudapp.azure.com",
    "ax-dev6-3dev.eastus.cloudapp.azure.com",
    "ax-dev7-3dev.eastus.cloudapp.azure.com",
    "ax-usamlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-ecumlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-uruicldev-3dev.eastus.cloudapp.azure.com",
    "ax-uruiclgld-3dev.eastus.cloudapp.azure.com"
]

def verificar_links():
    resultado_text.delete(1.0, tk.END)
    no_responde = False

    for link in link_list:
        resultado_text.insert(tk.END, f"Verificando el ping de {link}...\n")
        resultado_text.update_idletasks()

        result = subprocess.run(["ping", "-n", "4", link], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if result.returncode != 0:
            resultado_text.insert(tk.END, f"{link} NO RESPONDE AL PING, VERIFICAR AMBIENTE.\n", "error")
            no_responde = True
        else:
            resultado_text.insert(tk.END, f"{link} responde al ping.\n", "ok")

        resultado_text.insert(tk.END, "_____________________________________________________________________________________________________________\n")
        resultado_text.update_idletasks()

    resultado_text.insert(tk.END, "\n")
    if no_responde:
        resultado_text.insert(tk.END, "🔴 Al menos un enlace no respondió al ping.\n", "error")
    else:
        resultado_text.insert(tk.END, "🟢 Todos los enlaces respondieron al ping.\n", "ok")

# Crear ventana principal
ventana = tk.Tk()
ventana.title("Verificador de Ping")
ventana.geometry("900x600")

# Caja de resultados
resultado_text = scrolledtext.ScrolledText(ventana, wrap=tk.WORD, font=("Consolas", 10))
resultado_text.pack(expand=True, fill="both", padx=10, pady=10)

# Formato de colores
resultado_text.tag_config("error", foreground="red")
resultado_text.tag_config("ok", foreground="green")

# Botón para iniciar
boton_verificar = tk.Button(ventana, text="Iniciar Verificación", font=("Arial", 12), command=verificar_links)
boton_verificar.pack(pady=10)

# Ejecutar la app
ventana.mainloop()
