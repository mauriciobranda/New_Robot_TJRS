import os
import csv
import io # Importa o módulo io para String IO

def consolidar_csvs():
    # --- CONFIGURAÇÃO: CAMINHO DA PASTA DO GOOGLE DRIVE ---
    GOOGLE_DRIVE_SYNC_FOLDER = r'G:\My Drive\ProcessosRobo' # Caminho configurado do Google Drive

    # Define o diretório onde os CSVs individuais são gerados (pasta 'gen')
    input_csv_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'output', 'files', 'gen')

    # Define o nome para o arquivo CSV consolidado final
    consolidated_filename = 'processos_consolidados_todos.csv'

    # O arquivo consolidado será salvo DIRETAMENTE na pasta do Google Drive especificada
    consolidated_filepath = os.path.join(GOOGLE_DRIVE_SYNC_FOLDER, consolidated_filename)

    print(f"\n--- Iniciando a consolidação de arquivos CSV ---")
    print(f"Diretório de busca dos CSVs individuais: {input_csv_dir}")
    print(f"Arquivo de saída consolidado: {consolidated_filepath}")

    # 1. Remover o arquivo consolidado anterior, se existir, para garantir dados frescos
    if os.path.exists(consolidated_filepath):
        os.remove(consolidated_filepath)
        print(f"Arquivo consolidado existente '{consolidated_filename}' removido para recriação.")
    else:
        print(f"Nenhum arquivo consolidado '{consolidated_filename}' encontrado para remover. Será criado um novo.")

    # Lista para armazenar os caminhos completos dos arquivos CSV individuais a serem consolidados
    csv_files_to_process = []
    for root, _, files in os.walk(input_csv_dir):
        for file in files:
            if file.endswith('_processos.csv'):
                csv_files_to_process.append(os.path.join(root, file))

    if not csv_files_to_process:
        print("Nenhum arquivo CSV individual (terminando em '_processos.csv') encontrado para consolidar. Encerrando a consolidação.")
        return

    # 2. Processar os arquivos e consolidar no novo CSV
    header_written = False # Flag para controlar a escrita do cabeçalho
    total_rows_written = 0

    try:
        os.makedirs(os.path.dirname(consolidated_filepath), exist_ok=True)

        with open(consolidated_filepath, 'w', newline='', encoding='utf-8-sig') as outfile:
            writer = csv.writer(outfile, quoting=csv.QUOTE_ALL)

            for csv_file in sorted(csv_files_to_process):
                print(f"Processando arquivo: {os.path.basename(csv_file)}")
                try:
                    # Lê o conteúdo do arquivo individual primeiro, linha por linha
                    # e tenta limpar caracteres que podem causar problemas
                    with open(csv_file, 'r', encoding='utf-8') as infile:
                        raw_content = infile.read()
                        
                        # Substitui possíveis caracteres problemáticos (ex: quebras de linha não padrão)
                        # O .strip() remove espaços/quebras de linha extras no início/fim do arquivo.
                        # .replace('\r\n', '\n') padroniza quebras de linha para Unix style.
                        # Isso é uma tentativa de limpeza agressiva.
                        cleaned_content = raw_content.replace('\r\n', '\n').strip() 
                        
                        # Usa StringIO para tratar a string limpa como um arquivo
                        string_io_file = io.StringIO(cleaned_content)
                        reader = csv.reader(string_io_file)

                        header = next(reader)
                        if not header_written:
                            writer.writerow(header)
                            header_written = True

                        for row in reader:
                            # Antes de escrever, vamos garantir que cada item na linha
                            # não tenha quebras de linha ou caracteres invisíveis problemáticos
                            cleaned_row = [item.replace('\n', ' ').replace('\r', ' ').strip() for item in row]
                            writer.writerow(cleaned_row)
                            total_rows_written += 1

                except Exception as e:
                    print(f"AVISO: Não foi possível ler ou processar o arquivo '{os.path.basename(csv_file)}'. Erro: {e}")
                    continue

    except Exception as e:
        print(f"ERRO CRÍTICO: Falha ao criar ou escrever no arquivo consolidado '{consolidated_filename}'. Erro: {e}")
        return

    print(f"\nConsolidação concluída com sucesso!")
    print(f"Total de linhas de dados escritas no consolidado: {total_rows_written}")
    print(f"Arquivo consolidado final: {consolidated_filepath}")

    print("\nRemovendo arquivos CSV individuais da pasta de origem...")
    for csv_file in csv_files_to_process:
        try:
            os.remove(csv_file)
            print(f"Removido: {os.path.basename(csv_file)}")
        except Exception as e:
            print(f"AVISO: Não foi possível remover o arquivo individual '{os.path.basename(csv_file)}'. Erro: {e}")


if __name__ == "__main__":
    consolidar_csvs()