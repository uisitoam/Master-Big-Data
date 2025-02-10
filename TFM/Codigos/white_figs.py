import matplotlib.pyplot as plt

def save_figure_with_style(fig, original_path, styled_path):
    """
    Guarda una figura matplotlib en su formato original y luego aplica un estilo personalizado 
    (colores de texto y ejes en blanco, fondo transparente) antes de guardarla como PDF.

    Args:
        fig (matplotlib.figure.Figure): Figura a estilizar y guardar.
        original_path (str): Ruta donde se guardará la figura original.
        styled_path (str): Ruta donde se guardará la figura estilizada en formato PDF.
    """

    ax = fig.gca()

    fig.patch.set_alpha(0)  
    ax.set_facecolor('none')
    ax.spines['top'].set_color('white')
    ax.spines['right'].set_color('white')
    ax.spines['left'].set_color('white')
    ax.spines['bottom'].set_color('white')
    ax.xaxis.label.set_color('white')
    ax.yaxis.label.set_color('white')
    ax.tick_params(axis='x', colors='white')
    ax.tick_params(axis='y', colors='white')
    ax.title.set_color('white')
    legend = ax.get_legend()

    if legend:
        plt.setp(legend.get_texts(), color='white')
        legend.get_frame().set_facecolor('none')
        legend.get_frame().set_edgecolor('none')

    fig.savefig(styled_path, bbox_inches='tight', transparent=True)

def main():
    # Crear una figura ejemplo
    fig, ax = plt.subplots()
    ax.plot([1, 2, 3], [4, 5, 6])
    ax.set_title("Figura de ejemplo")
    
    # Rutas de ejemplo
    original_path = "figura_original.png"
    styled_path = "figura_estilizada.pdf"
    
    # Guardar la figura con estilo
    save_figure_with_style(fig, original_path, styled_path)
    print(f"Figura guardada en: {styled_path}")

if __name__ == '__main__':
    main()