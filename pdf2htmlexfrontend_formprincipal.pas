unit pdf2htmlexfrontend_formprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Process, LazStringUtils, FileUtil, LazFileUtils, LCLIntf, Menus;

type

  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    ButtonPdfHtmlExAtribuirValorPadrao: TButton;
    ButtonSalvarConfiguracao: TButton;
    ButtonConverter: TButton;
    ButtonRemoverLista: TButton;
    ButtonRemoverListaTodos: TButton;
    ButtonSelecionarArquivosPdf: TButton;
    ButtonSelecionarPastaSaida: TButton;
    CheckBoxPdfHtmlExHabilitado: TCheckBox;
    CheckBoxSubstituirArquivosAutomaticamente: TCheckBox;
    CheckBoxExibirConsoleProcessamento: TCheckBox;
    ComboBoxCodigoIncluirSecao: TComboBox;
    ComboBoxIncluirCodigo: TComboBox;
    ComboBoxPastaSaida: TComboBox;
    Label1: TLabel;
    LabelConfiguracaoXml: TLabel;
    LabeledEditPdfHtmlExParametro: TLabeledEdit;
    LabeledEditPdfHtmlExValor: TLabeledEdit;
    LabelManualHtml: TLabel;
    LabelArquivoPdf: TLabel;
    LabelTutorialVideo: TLabel;
    LabelCodigoFonte: TLabel;
    ListBoxPdfHtmlExConfig: TListBox;
    ListBoxArquivoPdf: TListBox;
    MemoOperacao: TMemo;
    Separator1: TMenuItem;
    MenuItemReiniciarPosicaoJanela: TMenuItem;
    MenuItemSair: TMenuItem;
    MenuItempdf2htmlEX: TMenuItem;
    OpenDialogPdf: TOpenDialog;
    PageControl1: TPageControl;
    PopupMenupdf2htmlEX: TPopupMenu;
    ProgressBarConversao: TProgressBar;
    SelectDirectoryDialogSaida: TSelectDirectoryDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TrayIconpdf2htmlEX: TTrayIcon;
    procedure ButtonSalvarConfiguracaoClick(Sender: TObject);
    procedure ButtonConverterClick(Sender: TObject);
    procedure ButtonPdfHtmlExAtribuirValorPadraoClick(Sender: TObject);
    procedure ButtonRemoverListaClick(Sender: TObject);
    procedure ButtonRemoverListaTodosClick(Sender: TObject);
    procedure ButtonSelecionarArquivosPdfClick(Sender: TObject);
    procedure ButtonSelecionarPastaSaidaClick(Sender: TObject);
    procedure CheckBoxPdfHtmlExHabilitadoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure LabelConfiguracaoXmlDblClick(Sender: TObject);
    procedure LabeledEditPdfHtmlExValorChange(Sender: TObject);
    procedure LabelManualHtmlClick(Sender: TObject);
    procedure LabelCodigoFonteClick(Sender: TObject);
    procedure LabelTutorialVideoClick(Sender: TObject);
    procedure ListBoxArquivoPdfClick(Sender: TObject);
    procedure ListBoxArquivoPdfDblClick(Sender: TObject);
    procedure ListBoxPdfHtmlExConfigClick(Sender: TObject);
    procedure MenuItemReiniciarPosicaoJanelaClick(Sender: TObject);
    procedure MenuItemSairClick(Sender: TObject);
  private

  public
    Versao: String;
    ArquivoXml: String;
    StringListConfig: TStringList;
    StringListXml: TStringList;
    StringListPdf: TStringList;
    UrlCodigoFonte: String;
    UrlTutorialVideo: String;
    ListBoxPdfHtmlExConfigurando: Boolean;

    function MyGetPart(GTag, GRegistro: String): String;
    function iGetPart(GTag1, GTag2, GRegistro: String): String;

    procedure GetFilesInDirs(Dir:string);
    procedure AddFile(Filename:string);
    procedure IncluiCodigo(PArquivoHtml: String);
    procedure SalvaConfiguracao;
  end;

var
  FormPrincipal: TFormPrincipal;

const
  allowedExtensions = '*.pdf';

implementation

{$R *.lfm}

{ TFormPrincipal }

function TFormPrincipal.MyGetPart(GTag, GRegistro: String): String;
begin
  try
    Result := GetPart(['<' + GTag + '>'], ['</' + GTag + '>'], GRegistro, False, False);
  except
    Result := '';
  end;
end;

function TFormPrincipal.iGetPart(GTag1, GTag2, GRegistro: String): String;
begin
  try
    Result := GetPart([GTag1], [GTag2], GRegistro, False, False);
  except
    Result := '';
  end;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
var
  FIncluirCodigo: String = '';
  FIncluirCodigoItens: String = '';
  FIncluirCodigoIndice: SmallInt = 0;
  FIncluirCodigoSecaoIndice: SmallInt = 0;
  FIndice: SmallInt;
begin
  Versao := '1.2';
  UrlCodigoFonte := 'https://github.com/ebarruda13/pdf2htmlexfrontend';
  UrlTutorialVideo := 'https://youtu.be/tg7nACwtZ0Y';

  LabelCodigoFonte.Hint := UrlCodigoFonte;
  LabelTutorialVideo.Hint := UrlTutorialVideo;

  FormPrincipal.Caption := 'pdf2htmlEX Frontend - Por Ericson Benjamim - versão ' + Versao;
  TrayIconpdf2htmlEX.Hint := FormPrincipal.Caption;

  ComboBoxPastaSaida.Items.Add('Mesma pasta do arquivo PDF');

  ComboBoxPastaSaida.ItemIndex := 0;

  ArquivoXml := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + 'pdf2htmlexfrontend.xml';

  LabelConfiguracaoXml.Caption := ArquivoXml;

  StringListXml := TStringList.Create;
  StringListPdf := TStringList.Create;
  StringListConfig := TStringList.Create;

  ListBoxPdfHtmlExConfigurando := false;

  if FileExists(ExtractFilePath(Application.ExeName) + 'pdf2htmlex_parametros.xml') then begin
    try
      StringListConfig.LoadFromFile(ExtractFilePath(Application.ExeName) + 'pdf2htmlex_parametros.xml');
    except
    end;
  end else begin
    with StringListConfig do begin
      Add('<parametro>first-page</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Primeira página a ser convertida</descricao>');
      Add('<parametro>last-page</parametro><valor>2147483647</valor>2147483647<padrao></padrao><habilitado>0</habilitado><descricao>Última página a ser convertida</descricao>');
      Add('<parametro>zoom</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Zoom (valor decimal)</descricao>');
      Add('<parametro>fit-width</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Ajuste de largura para N pixels (valor decimal)</descricao>');
      Add('<parametro>fit-height</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Ajuste de altura para N pixels (valor decimal)</descricao>');
      Add('<parametro>use-cropbox</parametro><valor>1</valor>1<padrao></padrao><habilitado>0</habilitado><descricao>Usa CropBox em vez de MediaBox</descricao>');
      Add('<parametro>hdpi</parametro><valor>144</valor><padrao>144</padrao><habilitado>0</habilitado><descricao>Resolução horizontal para gráficos em DPI</descricao>');
      Add('<parametro>vdpi</parametro><valor>144</valor><padrao>144</padrao><habilitado>0</habilitado><descricao>Resolução vertical para gráficos em DPI</descricao>');
      Add('<parametro>embed</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Especifica quais elementos devem ser incorporados na saída</descricao>');
      Add('<parametro>embed-css</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora arquivos CSS na saída</descricao>');
      Add('<parametro>embed-font</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora arquivos arquivos de fonte na saída</descricao>');
      Add('<parametro>embed-image</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora arquivos arquivos de imagem na saída</descricao>');
      Add('<parametro>embed-javascript</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora arquivos JavaScript na saída</descricao>');
      Add('<parametro>embed-outline</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora arquivos contornos na saída</descricao>');
      Add('<parametro>split-pages</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Divide as páginas em arquivos separados</descricao>');
      Add('<parametro>dest-dir</parametro><valor></valor><padrao>.</padrao><habilitado>0</habilitado><descricao>Especifica o diretório de destino</descricao>');
      Add('<parametro>css-filename</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Nome do arquivo CSS gerado</descricao>');
      Add('<parametro>page-filename</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Modelo de nome de arquivo para páginas divididas</descricao>');
      Add('<parametro>outline-filename</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Nome do arquivo de estrutura de tópicos gerado</descricao>');
      Add('<parametro>process-nontext</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Renderiza gráficos além de texto</descricao>');
      Add('<parametro>process-outline</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Mostra o esboço em HTML</descricao>');
      Add('<parametro>process-annotation</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Mostra anotação em HTML</descricao>');
      Add('<parametro>process-form</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Inclui campos de texto e botões de opção</descricao>');
      Add('<parametro>printing</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Ativar suporte de impressão</descricao>');
      Add('<parametro>fallback</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Saída no modo fallback</descricao>');
      Add('<parametro>tmp-file-size-limit</parametro><valor>-1</valor><padrao>-1</padrao><habilitado>0</habilitado><descricao>Tamanho máximo (em KB) usado por arquivos temporários, -1 para sem limite</descricao>');
      Add('<parametro>embed-external-font</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora correspondência local para fontes externas</descricao>');
      Add('<parametro>font-format</parametro><valor>woff</valor><padrao>woff</padrao><habilitado>0</habilitado><descricao>Sufixo para arquivos de fontes incorporadas (ttf,otf,woff,svg)</descricao>');
      Add('<parametro>decompose-ligature</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Decompõe ligaduras, como ´¼ü -> fi</descricao>');
      Add('<parametro>auto-hint</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Use "fontforge autohint" em fontes sem dicas</descricao>');
      Add('<parametro>external-hint-tool</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Ferramenta externa para fontes com dicas (substitui --auto-hint)</descricao>');
      Add('<parametro>stretch-narrow-glyph</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Alonga glifos estreitos em vez de preenchê-los</descricao>');
      Add('<parametro>squeeze-wide-glyph</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Reduz glifos largos em vez de truncá-los</descricao>');
      Add('<parametro>override-fstype</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Limpa os bits fstype em fontes TTF/OTF</descricao>');
      Add('<parametro>process-type3</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Converte fontes Tipo 3 para web (experimental)</descricao>');
      Add('<parametro>heps</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Limite horizontal para mesclar texto, em pixels</descricao>');
      Add('<parametro>veps</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Limite vertical para mesclar texto, em pixels</descricao>');
      Add('<parametro>space-threshold</parametro><valor>0.125</valor><padrao>0.125</padrao><habilitado>0</habilitado><descricao>Limite de quebra de palavra (limiar * em) (padrão: 0.125)</descricao>');
      Add('<parametro>font-size-multiplier</parametro><valor>4</valor><padrao>4</padrao><habilitado>0</habilitado><descricao>Um valor maior que 1 aumenta a precisão da renderização</descricao>');
      Add('<parametro>space-as-offset</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Trata caracteres de espaço como deslocamentos</descricao>');
      Add('<parametro>tounicode</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Como lidar com ToUnicode CMaps (0=auto, 1=forçar, -1=ignorar)</descricao>');
      Add('<parametro>optimize-text</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Tenta reduzir o número de elementos HTML usados para texto</descricao>');
      Add('<parametro>correct-text-visibility</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Tenta detectar textos cobertos por outros gráficos e organizá-los adequadamente</descricao>');
      Add('<parametro>bg-format</parametro><valor>png</valor><padrao>png</padrao><habilitado>0</habilitado><descricao>Especifica o formato da imagem de fundo</descricao>');
      Add('<parametro>svg-node-count-limit</parametro><valor>-1</valor><padrao>-1</padrao><habilitado>0</habilitado><descricao>Se a contagem de nós em uma imagem de fundo SVG exceder esse limite, retorne esta página para o fundo de bitmap; valor negativo significa sem limite</descricao>');
      Add('<parametro>svg-embed-bitmap</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Incorpora bitmaps em plano de fundo SVG; 0: despeje bitmaps em arquivos externos, se possível</descricao>');
      Add('<parametro>owner-password</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Senha do proprietário (para arquivos criptografados)</descricao>');
      Add('<parametro>user-password</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Senha do usuário (para arquivos criptografados)</descricao>');
      Add('<parametro>no-drm</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Substitui configurações de DRM do documento</descricao>');
      Add('<parametro>clean-tmp</parametro><valor>1</valor><padrao>1</padrao><habilitado>0</habilitado><descricao>Remove arquivos temporários após a conversão</descricao>');
      Add('<parametro>tmp-dir</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Especifica a localização do diretório temporário. (padrão: "C:\Usuários\%nomedeusuário%\AppData\Local\Temp")</descricao>)');
      Add('<parametro>data-dir</parametro><valor></valor><padrao></padrao><habilitado>0</habilitado><descricao>Especifica o diretório de dados (padrão: "%execdir%/data")</descricao>');
      Add('<parametro>debug</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Imprime informações de depuração</descricao>');
      Add('<parametro>proof</parametro><valor>0</valor><padrao>0</padrao><habilitado>0</habilitado><descricao>Textos são desenhados na camada de texto e no fundo para prova</descricao>');
    end;

    try
      StringListConfig.SaveToFile(ExtractFilePath(Application.ExeName) + 'pdf2htmlex_parametros.xml');
    except
    end;
  end;

  if StringListConfig.Count > 0 then begin
    StringListConfig.Sort;

    for FIndice := 0 to StringListConfig.Count - 1 do begin
      if Length(Trim(MyGetPart('parametro', StringListConfig.Strings[FIndice]))) > 0 then begin
        ListBoxPdfHtmlExConfig.Items.Add(MyGetPart('parametro', StringListConfig.Strings[FIndice]) + ': ' + MyGetPart('valor', StringListConfig.Strings[FIndice]));
      end;
    end;
  end;

  try
    StringListXml.LoadFromFile(ArquivoXml);
  except
  end;

  FormPrincipal.Top := StrToIntDef(MyGetPart('topo', StringListXml.Text), FormPrincipal.Top);
  FormPrincipal.Left := StrToIntDef(MyGetPart('esquerda', StringListXml.Text), FormPrincipal.Left);
  FIncluirCodigoIndice := StrToIntDef(MyGetPart('incluir_codigo_indice', StringListXml.Text), 0);
  FIncluirCodigoSecaoIndice := StrToIntDef(MyGetPart('incluir_codigo_secao_indice', StringListXml.Text), 0);

  with ComboBoxCodigoIncluirSecao.Items do
    begin
      Add('Após a seção <head>');
      Add('Antes da seção </head>');
      Add('Após a seção <body>');
      Add('Antes da seção </body>');
    end;

  if FIncluirCodigoSecaoIndice < ComboBoxCodigoIncluirSecao.Items.Count then
    ComboBoxCodigoIncluirSecao.ItemIndex := FIncluirCodigoSecaoIndice
  else
    ComboBoxCodigoIncluirSecao.ItemIndex := 0;

  ComboBoxIncluirCodigo.Items.Add('Não incluir');

  FIncluirCodigoItens := MyGetPart('incluir_codigo_itens', StringListXml.Text);

  while (Pos('<codigo>', FIncluirCodigoItens) > 0) and (Pos('</codigo>', FIncluirCodigoItens) > 0) do
    begin
      FIncluirCodigo := MyGetPart('codigo', FIncluirCodigoItens);

      ComboBoxIncluirCodigo.Items.Add(FIncluirCodigo);

      FIncluirCodigoItens := StringReplace(FIncluirCodigoItens, '<codigo>' + FIncluirCodigo + '</codigo>', '', [rfReplaceAll]);
    end;

  if ComboBoxIncluirCodigo.Items.Count = 1 then
    begin
      ComboBoxIncluirCodigo.Items.Add('Rybena Produção: <script type="text/javascript" src="https://normasinternas.trt13.jus.br/xmlui/themes/trt7/scripts/rybena.js"></script>');
      ComboBoxIncluirCodigo.Items.Add('Rybena Homologação: <script type="text/javascript" src="https://sistemas-hml.trt13.jus.br/xmlui/themes/trt7/scripts/rybena.js"></script>');
    end;

  if FIncluirCodigoIndice < ComboBoxIncluirCodigo.Items.Count then
    ComboBoxIncluirCodigo.ItemIndex := FIncluirCodigoIndice
  else
    ComboBoxIncluirCodigo.ItemIndex := 0;

  PageControl1.ActivePageIndex := 0;
end;

procedure TFormPrincipal.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  RowCounter, Counter: Integer;
begin
  for Counter := 0 to Length(FileNames) - 1 do
    begin
      if DirectoryExists(FileNames[Counter]) then
        GetFilesInDirs(FileNames[Counter])
      else
        AddFile(FileNames[Counter]);
    end;
end;

procedure TFormPrincipal.LabelConfiguracaoXmlDblClick(Sender: TObject);
begin
  OpenDocument(ArquivoXml);
end;

procedure TFormPrincipal.GetFilesInDirs(Dir: string);
var
  DirInfo: TSearchRec;
begin
  if FindFirst(Dir + DirectorySeparator + '*', faAnyFile and faDirectory, DirInfo) = 0 then
    repeat
      if (DirInfo.Attr and faDirectory) = faDirectory then // it's a dir - go get files in dir
        begin
          if (DirInfo.Name <> '.') and (DirInfo.Name <> '..') then
            GetFilesInDirs(Dir + DirectorySeparator + DirInfo.Name);
        end
      else  // It's a file; add it
        AddFile(Dir + DirectorySeparator + DirInfo.Name);
    until FindNext(DirInfo) <> 0;

  FindClose(DirInfo);
end;

procedure TFormPrincipal.AddFile(Filename: string);
begin
  if (FileName <> '') and (Pos(LowerCase(ExtractFileExt(Filename)), allowedExtensions) > 0) then begin
    if StringListPdf.IndexOf(Filename) < 0 then begin
      StringListPdf.AddStrings(Filename);
      ListBoxArquivoPdf.Items.add(Filename);
    end;
  end;
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SalvaConfiguracao;

  StringListXml.Free;
  StringListPdf.Free;
  StringListConfig.Free;
end;

procedure TFormPrincipal.SalvaConfiguracao;
var
  FIndice: SmallInt;
begin
  try
    StringListXml.Clear;

    with StringListXml do begin
      Add('<?xml version="1.0" encoding="UTF-8"?>');
      Add('<pdf2htmlexfrontend>');
      Add('<topo>' + FormPrincipal.Top.ToString + '</topo>');
      Add('<esquerda>' + FormPrincipal.Left.ToString + '</esquerda>');
      Add('<incluir_codigo_indice>' + ComboBoxIncluirCodigo.ItemIndex.ToString + '</incluir_codigo_indice>');
      Add('<incluir_codigo_secao_indice>' + ComboBoxCodigoIncluirSecao.ItemIndex.ToString + '</incluir_codigo_secao_indice>');

      if ComboBoxIncluirCodigo.Items.Count > 1 then
        begin
          for FIndice := 1 to ComboBoxIncluirCodigo.Items.Count - 1 do
            begin
              Add('<codigo>' + ComboBoxIncluirCodigo.Items.Strings[FIndice] + '</codigo>');
            end;
        end;

      Add('</pdf2htmlexfrontend>');
    end;

    StringListXml.SaveToFile(ArquivoXml);
  except
  end;

  try
    StringListConfig.SaveToFile(ExtractFilePath(Application.ExeName) + 'pdf2htmlex_parametros.xml');
  except
  end;
end;

procedure TFormPrincipal.ListBoxArquivoPdfClick(Sender: TObject);
begin
  if ListBoxArquivoPdf.ItemIndex < 0 then begin
    ListBoxArquivoPdf.Hint := '';
    LabelArquivoPdf.Caption := '-';
  end else begin
    ListBoxArquivoPdf.Hint := StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex];
    LabelArquivoPdf.Caption := ExtractFileName(StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex]);
  end;
end;

procedure TFormPrincipal.ListBoxArquivoPdfDblClick(Sender: TObject);
var
  Resultado: Integer;
  PastaSaida: String;
  ArquivoHtml: String;
begin
  if ListBoxArquivoPdf.ItemIndex > -1 then begin
    if ComboBoxPastaSaida.ItemIndex = 0 then begin
      PastaSaida := ExtractFilePath(StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex]);
    end else begin
      PastaSaida := IncludeTrailingPathDelimiter(ComboBoxPastaSaida.Text);
    end;

    ArquivoHtml := PastaSaida + ExtractFileNameOnly(StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex]) + '.html';

    if FileExists(ArquivoHtml) then
      Resultado := QuestionDlg('Atenção', 'Abrir arquivo "' + ExtractFileNameOnly(StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex]) + '"?', mtCustom, [mrYes, '&PDF', mrOK, '&HTML', mrCancel, '&Cancelar'], '')
    else
      Resultado := QuestionDlg('Atenção', 'Abrir arquivo "' + ExtractFileNameOnly(StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex]) + '"?', mtCustom, [mrYes, '&PDF', mrCancel, '&Cancelar'], '');

    if Resultado = mrYes then begin
      OpenDocument(StringListPdf.Strings[ListBoxArquivoPdf.ItemIndex]);
    end else begin
      if Resultado = mrOK then begin
        OpenDocument(ArquivoHtml);
      end;
    end;
  end;
end;

procedure TFormPrincipal.ListBoxPdfHtmlExConfigClick(Sender: TObject);
begin
  ListBoxPdfHtmlExConfigurando := true;

  if ListBoxPdfHtmlExConfig.ItemIndex > -1 then begin
    try
      LabeledEditPdfHtmlExParametro.Text := MyGetPart('parametro', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      LabeledEditPdfHtmlExValor.Text := MyGetPart('valor', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      CheckBoxPdfHtmlExHabilitado.Checked := StrToBoolDef(MyGetPart('habilitado', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]), false);
    except
    end;
  end;

  ListBoxPdfHtmlExConfigurando := false;
end;

procedure TFormPrincipal.LabeledEditPdfHtmlExValorChange(Sender: TObject);
var
  FParametro: String;
  FValor: String;
  FPadrao: String;
  FHabilitado: String;
  FDescricao: String;
begin
  if (ListBoxPdfHtmlExConfig.ItemIndex > -1) and not ListBoxPdfHtmlExConfigurando then begin
    ListBoxPdfHtmlExConfigurando := true;

    try
      FParametro := LabeledEditPdfHtmlExParametro.Text;
      FValor := LabeledEditPdfHtmlExValor.Text;
      FHabilitado := BoolToStr(CheckBoxPdfHtmlExHabilitado.Checked, '1', '0');

      FPadrao := MyGetPart('padrao', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      FDescricao := MyGetPart('descricao', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);

      StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex] :=
        '<parametro>' + FParametro + '</parametro>' +
        '<valor>' + FValor + '</valor>' +
        '<padrao>' + FPadrao + '</padrao>' +
        '<habilitado>' + FHabilitado + '</habilitado>' +
        '<descricao>' + FDescricao + '</descricao>';

      ListBoxPdfHtmlExConfig.Items.Strings[ListBoxPdfHtmlExConfig.ItemIndex] := FParametro + ': ' + FValor;
    except
    end;

    ListBoxPdfHtmlExConfigurando := false;
  end;
end;

procedure TFormPrincipal.CheckBoxPdfHtmlExHabilitadoChange(Sender: TObject);
var
  FParametro: String;
  FValor: String;
  FPadrao: String;
  FHabilitado: String;
  FDescricao: String;
begin
  if (ListBoxPdfHtmlExConfig.ItemIndex > -1) and not ListBoxPdfHtmlExConfigurando then begin
    ListBoxPdfHtmlExConfigurando := true;

    try
      FParametro := MyGetPart('parametro', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      FValor := MyGetPart('valor', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      FHabilitado := BoolToStr(CheckBoxPdfHtmlExHabilitado.Checked, '1', '0');

      FPadrao := MyGetPart('padrao', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      FDescricao := MyGetPart('descricao', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);

      StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex] :=
        '<parametro>' + FParametro + '</parametro>' +
        '<valor>' + FValor + '</valor>' +
        '<padrao>' + FPadrao + '</padrao>' +
        '<habilitado>' + FHabilitado + '</habilitado>' +
        '<descricao>' + FDescricao + '</descricao>';

      ListBoxPdfHtmlExConfig.Items.Strings[ListBoxPdfHtmlExConfig.ItemIndex] := FParametro + ': ' + FValor;
    except
    end;

    ListBoxPdfHtmlExConfigurando := false;
  end;
end;

procedure TFormPrincipal.ButtonPdfHtmlExAtribuirValorPadraoClick(Sender: TObject);
var
  FParametro: String;
  FPadrao: String;
  FHabilitado: String;
  FDescricao: String;
begin
  if ListBoxPdfHtmlExConfig.ItemIndex > -1 then begin
    try
      FParametro := LabeledEditPdfHtmlExParametro.Text;
      FHabilitado := BoolToStr(CheckBoxPdfHtmlExHabilitado.Checked, '1', '0');

      FPadrao := MyGetPart('padrao', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);
      FDescricao := MyGetPart('descricao', StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex]);

      LabeledEditPdfHtmlExValor.Text := FPadrao;

      StringListConfig.Strings[ListBoxPdfHtmlExConfig.ItemIndex] :=
        '<parametro>' + FParametro + '</parametro>' +
        '<valor>' + FPadrao + '</valor>' +
        '<padrao>' + FPadrao + '</padrao>' +
        '<habilitado>' + FHabilitado + '</habilitado>' +
        '<descricao>' + FDescricao + '</descricao>';

      ListBoxPdfHtmlExConfig.Items.Strings[ListBoxPdfHtmlExConfig.ItemIndex] := FParametro + ': ' + FPadrao;
    except
    end;
  end;
end;

procedure TFormPrincipal.MenuItemReiniciarPosicaoJanelaClick(Sender: TObject);
begin
  FormPrincipal.Left := 50;
  FormPrincipal.Top := 50;
end;

procedure TFormPrincipal.MenuItemSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.ButtonSelecionarArquivosPdfClick(Sender: TObject);
var
  Indice: Integer;
  StringListPdfAux: TStringlist;
begin
  if OpenDialogPdf.Execute then begin
    ListBoxArquivoPdf.Hint := '';
    LabelArquivoPdf.Caption := '-';

    StringListPdfAux := TStringlist.Create;

    StringListPdfAux.AddStrings(OpenDialogPdf.Files);

    if StringListPdfAux.Count > 0 then begin
      for Indice := 0 to StringListPdfAux.Count - 1 do begin
        if StringListPdf.IndexOf(StringListPdfAux.Strings[Indice]) < 0 then begin
          StringListPdf.Add(StringListPdfAux.Strings[Indice]);
          ListBoxArquivoPdf.Items.Add(StringListPdfAux.Strings[Indice]);
        end;
      end;
    end;

    StringListPdfAux.Free;
  end;
end;

procedure TFormPrincipal.ButtonSelecionarPastaSaidaClick(Sender: TObject);
begin
  if SelectDirectoryDialogSaida.Execute then begin
    if ComboBoxPastaSaida.Items.IndexOf(SelectDirectoryDialogSaida.FileName) < 0 then begin
      ComboBoxPastaSaida.Items.Add(SelectDirectoryDialogSaida.FileName);
    end;

    ComboBoxPastaSaida.Text := SelectDirectoryDialogSaida.FileName;
  end;
end;

procedure TFormPrincipal.ButtonRemoverListaTodosClick(Sender: TObject);
begin
  StringListPdf.Clear;
  ListBoxArquivoPdf.Clear;
  ListBoxArquivoPdf.Hint := '';
  LabelArquivoPdf.Caption :=  '-';
end;

procedure TFormPrincipal.ButtonRemoverListaClick(Sender: TObject);
var
  Indice: SmallInt;
begin
  if ListBoxArquivoPdf.Items.Count > 0 then begin
    for Indice := ListBoxArquivoPdf.Items.Count - 1 downto 0 do begin
      if ListBoxArquivoPdf.Selected[Indice] then begin
        StringListPdf.Delete(Indice);
        ListBoxArquivoPdf.Items.Delete(Indice);
      end;
    end;
  end;

  LabelArquivoPdf.Caption :=  '-';
  ListBoxArquivoPdf.Hint := '';
  ListBoxArquivoPdf.ItemIndex := -1;
end;

procedure TFormPrincipal.ButtonConverterClick(Sender: TObject);
var
  FIndice: SmallInt;
  FCopiar: Boolean;
  FPastaSaida: String;
  FArquivoHtml: String;
  FArquivoTmp: String;
  FProcessPdf2htmlex: TProcess;
  FSimboloResultado: String;
  FIndiceConfig: SmallInt;
  FParametro: String;
  FValor: String;
  FHabilitado: String;
begin
  ProgressBarConversao.Position := 0;

  MemoOperacao.Lines.Clear;

  ListBoxArquivoPdf.Items.Assign(StringListPdf);

  if ListBoxArquivoPdf.Items.Count > 0 then begin
    ProgressBarConversao.Max := ListBoxArquivoPdf.Items.Count - 1;
    FProcessPdf2htmlex := TProcess.Create(nil);
    FProcessPdf2htmlex.ConsoleTitle := 'pdf2htmlex - não feche esta janela, ela será fechada automaticamente';

    FProcessPdf2htmlex.Executable := ExtractFilePath(Application.ExeName) + 'pdf2htmlex\pdf2htmlEX.exe';
    FProcessPdf2htmlex.CurrentDirectory := ExtractFilePath(Application.ExeName) + 'pdf2htmlex\';

    MemoOperacao.Lines.Add('Início: ' + DateTimeToStr(Now));
    MemoOperacao.Lines.Add('Pasta pdf2htmlEX: ' + FProcessPdf2htmlex.CurrentDirectory);
    MemoOperacao.Lines.Add('Executável pdf2htmlEX: ' + FProcessPdf2htmlex.Executable);
    MemoOperacao.Lines.Add('---');

    if not CheckBoxExibirConsoleProcessamento.Checked then FProcessPdf2htmlex.ShowWindow := swoMinimize;

    FProcessPdf2htmlex.Options := FProcessPdf2htmlex.Options + [poWaitOnExit];

    for FIndice := 0 to ListBoxArquivoPdf.Items.Count - 1 do begin
      FSimboloResultado := '';
      ListBoxArquivoPdf.ItemIndex := FIndice;
      ListBoxArquivoPdf.Hint := StringListPdf.Strings[FIndice];
      LabelArquivoPdf.Caption := ExtractFileName(StringListPdf.Strings[FIndice]);

      FProcessPdf2htmlex.Parameters.Clear;

      // --dest-dir

      FProcessPdf2htmlex.Parameters.Add('--embed-outline=0'); // https://github.com/coolwanglu/pdf2htmlEX/wiki/Command-Line-Options

      if StringListConfig.Count > 0 then begin
        for FIndiceConfig := 0 to StringListConfig.Count - 1 do begin
          FParametro := MyGetPart('parametro', StringListConfig.Strings[FIndiceConfig]);
          FHabilitado := MyGetPart('habilitado', StringListConfig.Strings[FIndiceConfig]);
          FValor := MyGetPart('valor', StringListConfig.Strings[FIndiceConfig]);

          if (Length(Trim(FParametro)) > 0) and (Length(Trim(FValor)) > 0) and StrToBoolDef(FHabilitado, false) then begin
            FProcessPdf2htmlex.Parameters.Add('--' + FParametro + '=' + FValor);
          end;
        end;
      end;

      MemoOperacao.Lines.Add('Arquivo PDF ' + (FIndice + 1).ToString + ': ' + StringListPdf.Strings[FIndice]);

      FArquivoTmp := 'arquivo_html_' + (FIndice + 1).ToString + '.tmp';

      MemoOperacao.Lines.Add('Arquivo temporário ' + (FIndice + 1).ToString + ': ' + FArquivoTmp);

      FProcessPdf2htmlex.Parameters.Add(StringListPdf.Strings[FIndice]);
      FProcessPdf2htmlex.Parameters.Add(FArquivoTmp);

      //ProcessPdf2htmlex.Parameters.SaveToFile('_ProcessPdf2htmlex.bat');

      try
        FProcessPdf2htmlex.Execute;

        FSimboloResultado := '+';
      except
        FSimboloResultado := '*';
      end;

      ListBoxArquivoPdf.Items.Strings[FIndice] := FSimboloResultado + ' ' + StringListPdf.Strings[FIndice];

      ProgressBarConversao.Position := FIndice;

      Application.ProcessMessages;

      if ComboBoxPastaSaida.ItemIndex = 0 then begin
        FPastaSaida := ExtractFilePath(StringListPdf.Strings[FIndice]);
      end else begin
        FPastaSaida := IncludeTrailingPathDelimiter(ComboBoxPastaSaida.Text);
      end;

      FArquivoHtml := FPastaSaida + ExtractFileNameOnly(StringListPdf.Strings[FIndice]) + '.html';

      MemoOperacao.Lines.Add('Arquivo destino ' + (FIndice + 1).ToString + ': ' + FArquivoHtml);

      if CheckBoxSubstituirArquivosAutomaticamente.Checked then begin
        FCopiar := true;
      end else begin
        if FileExists(FArquivoHtml) then begin
          if QuestionDlg('Atenção','Confirma substituição do arquivo ' + FArquivoHtml + '?', mtCustom, [mrYes, '&Sim', mrNo, '&Não'], '') = mrYes then begin
            FCopiar := true;
          end else begin
            FCopiar := false;
          end;
        end;
      end;

      if ComboBoxIncluirCodigo.ItemIndex > 0 then
        begin
          MemoOperacao.Lines.Add('Incluindo código...');

          IncluiCodigo(FProcessPdf2htmlex.CurrentDirectory + FArquivoTmp);

          MemoOperacao.Lines.Add('Código incluído.');
        end;

      if FCopiar then begin
        try
          CopyFile(FProcessPdf2htmlex.CurrentDirectory + FArquivoTmp, FArquivoHtml);

          FSimboloResultado := FSimboloResultado + '+';
        except
          FSimboloResultado := FSimboloResultado + '*';
        end;
      end else begin
        FSimboloResultado := FSimboloResultado + '!';
      end;

      ListBoxArquivoPdf.Items.Strings[FIndice] := FSimboloResultado + ' ' + StringListPdf.Strings[FIndice];

      try
        DeleteFile(FProcessPdf2htmlex.CurrentDirectory + FArquivoTmp);

        FSimboloResultado := FSimboloResultado + '+';
      except
        FSimboloResultado := FSimboloResultado + '*';
      end;

      ListBoxArquivoPdf.Items.Strings[FIndice] := FSimboloResultado + ' ' + StringListPdf.Strings[FIndice];

      MemoOperacao.Lines.Add('---');
    end;

    MemoOperacao.Lines.Add('Fim: ' + DateTimeToStr(Now));

    FProcessPdf2htmlex.Free;

    ListBoxArquivoPdf.ItemIndex := -1;
    ListBoxArquivoPdf.Hint := '';
    LabelArquivoPdf.Caption :=  'Conversão concluída.';
  end;
end;

procedure TFormPrincipal.ButtonSalvarConfiguracaoClick(Sender: TObject);
begin
  SalvaConfiguracao;
end;

procedure TFormPrincipal.IncluiCodigo(PArquivoHtml: String);
var
  FStringListHtml: TStringlist;
  FSecao: String;
  FSecaoParametros: String;
  FCodigoIncluir: String;
begin
  FStringListHtml := TStringlist.Create;

  try
    FStringListHtml.LoadFromFile(PArquivoHtml);
  except
  end;

  if FStringListHtml.Count > 0 then
    begin
      FCodigoIncluir := ComboBoxIncluirCodigo.Items.Strings[ComboBoxIncluirCodigo.ItemIndex];

      if Pos(': ', FCodigoIncluir) > 0 then
        begin
           Delete(FCodigoIncluir, 1, Pos(': ', FCodigoIncluir) + 1);
        end;

      if ComboBoxCodigoIncluirSecao.ItemIndex < 1 then FSecao := '<head';
      if ComboBoxCodigoIncluirSecao.ItemIndex = 1 then FSecao := '</head';
      if ComboBoxCodigoIncluirSecao.ItemIndex = 2 then FSecao := '<body';
      if ComboBoxCodigoIncluirSecao.ItemIndex = 3 then FSecao := '</body';

      FSecaoParametros := iGetPart(FSecao, '>', FStringListHtml.Text) + '>';

      if Pos(FSecao, FStringListHtml.Text) > 0 then
        begin
          if Pos('/', FSecao) > 0 then
            begin
              FStringListHtml.Text := StringReplace(FStringListHtml.Text, FSecao + FSecaoParametros, FCodigoIncluir + FSecao + FSecaoParametros, [rfReplaceAll]);
            end
          else
            begin
              FStringListHtml.Text := StringReplace(FStringListHtml.Text, FSecao + FSecaoParametros, FSecao + FSecaoParametros + FCodigoIncluir, [rfReplaceAll]);
            end;

          try
            FStringListHtml.SaveToFile(PArquivoHtml);
          except
          end;
        end;
    end;

  FStringListHtml.Free;
end;

procedure TFormPrincipal.LabelManualHtmlClick(Sender: TObject);
begin
  OpenDocument(ExtractFilePath(Application.ExeName) + 'pdf2htmlexfrontend_manual.xhtml');
end;

procedure TFormPrincipal.LabelCodigoFonteClick(Sender: TObject);
begin
  OpenURL(UrlCodigoFonte);
end;

procedure TFormPrincipal.LabelTutorialVideoClick(Sender: TObject);
begin
  OpenURL(UrlTutorialVideo);
end;

end.

