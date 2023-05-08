unit pdf2htmlexfrontend_formprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Process, LazStringUtils, FileUtil, LazFileUtils, LCLIntf;

type

  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    ButtonConverter: TButton;
    ButtonRemoverLista: TButton;
    ButtonRemoverListaTodos: TButton;
    ButtonSelecionarArquivosPdf: TButton;
    ButtonSelecionarPastaSaida: TButton;
    CheckBoxSubstituirArquivosAutomaticamente: TCheckBox;
    CheckBoxExibirConsoleProcessamento: TCheckBox;
    ComboBoxCodigoIncluirSecao: TComboBox;
    ComboBoxIncluirCodigo: TComboBox;
    ComboBoxPastaSaida: TComboBox;
    Label1: TLabel;
    LabelConfiguracaoXml: TLabel;
    LabelManualHtml: TLabel;
    LabelArquivoPdf: TLabel;
    LabelTutorialVideo: TLabel;
    LabelCodigoFonte: TLabel;
    ListBoxArquivoPdf: TListBox;
    MemoOperacao: TMemo;
    OpenDialogPdf: TOpenDialog;
    PageControl1: TPageControl;
    ProgressBarConversao: TProgressBar;
    SelectDirectoryDialogSaida: TSelectDirectoryDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure ButtonConverterClick(Sender: TObject);
    procedure ButtonRemoverListaClick(Sender: TObject);
    procedure ButtonRemoverListaTodosClick(Sender: TObject);
    procedure ButtonSelecionarArquivosPdfClick(Sender: TObject);
    procedure ButtonSelecionarPastaSaidaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure LabelConfiguracaoXmlDblClick(Sender: TObject);
    procedure LabelManualHtmlClick(Sender: TObject);
    procedure LabelCodigoFonteClick(Sender: TObject);
    procedure LabelTutorialVideoClick(Sender: TObject);
    procedure ListBoxArquivoPdfClick(Sender: TObject);
    procedure ListBoxArquivoPdfDblClick(Sender: TObject);
  private

  public
    ArquivoXml: String;
    StringListXml: TStringList;
    StringListPdf: TStringList;
    UrlCodigoFonte: String;
    UrlTutorialVideo: String;

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
begin
  UrlCodigoFonte := 'https://github.com/ebarruda13/pdf2htmlexfrontend';
  UrlTutorialVideo := 'https://youtu.be/tg7nACwtZ0Y';

  LabelCodigoFonte.Hint := UrlCodigoFonte;
  LabelTutorialVideo.Hint := UrlTutorialVideo;

  ComboBoxPastaSaida.Items.Add('Mesma pasta do arquivo PDF');

  ComboBoxPastaSaida.ItemIndex := 0;

  ArquivoXml := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + 'pdf2htmlexfrontend.xml';

  LabelConfiguracaoXml.Caption := ArquivoXml;

  StringListXml := TStringList.Create;
  StringListPdf := TStringList.Create;

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

  StringListXml.Free;
  StringListPdf.Free;
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
  Indice: SmallInt;
  Copiar: Boolean;
  PastaSaida: String;
  ArquivoHtml: String;
  ArquivoTmp: String;
  ProcessPdf2htmlex: TProcess;
  SimboloResultado: String;
begin
  ProgressBarConversao.Position := 0;

  MemoOperacao.Lines.Clear;

  ListBoxArquivoPdf.Items.Assign(StringListPdf);

  if ListBoxArquivoPdf.Items.Count > 0 then begin
    ProgressBarConversao.Max := ListBoxArquivoPdf.Items.Count - 1;
    ProcessPdf2htmlex := TProcess.Create(nil);
    ProcessPdf2htmlex.ConsoleTitle := 'pdf2htmlex - não feche esta janela, ela será fechada automaticamente';

    ProcessPdf2htmlex.Executable := ExtractFilePath(Application.ExeName) + 'pdf2htmlex\pdf2htmlEX.exe';
    ProcessPdf2htmlex.CurrentDirectory := ExtractFilePath(Application.ExeName) + 'pdf2htmlex\';

    MemoOperacao.Lines.Add('Início: ' + DateTimeToStr(Now));
    MemoOperacao.Lines.Add('Pasta pdf2htmlEX: ' + ProcessPdf2htmlex.CurrentDirectory);
    MemoOperacao.Lines.Add('Executável pdf2htmlEX: ' + ProcessPdf2htmlex.Executable);
    MemoOperacao.Lines.Add('---');

    if not CheckBoxExibirConsoleProcessamento.Checked then ProcessPdf2htmlex.ShowWindow := swoMinimize;

    ProcessPdf2htmlex.Options := ProcessPdf2htmlex.Options + [poWaitOnExit];

    for Indice := 0 to ListBoxArquivoPdf.Items.Count - 1 do begin
      SimboloResultado := '';
      ListBoxArquivoPdf.ItemIndex := Indice;
      ListBoxArquivoPdf.Hint := StringListPdf.Strings[Indice];
      LabelArquivoPdf.Caption := ExtractFileName(StringListPdf.Strings[Indice]);

      ProcessPdf2htmlex.Parameters.Clear;

      MemoOperacao.Lines.Add('Arquivo PDF ' + (Indice + 1).ToString + ': ' + StringListPdf.Strings[Indice]);

      ArquivoTmp := 'arquivo_html_' + (Indice + 1).ToString + '.tmp';

      MemoOperacao.Lines.Add('Arquivo temporário ' + (Indice + 1).ToString + ': ' + ArquivoTmp);

      ProcessPdf2htmlex.Parameters.Add(StringListPdf.Strings[Indice]);
      ProcessPdf2htmlex.Parameters.Add(ArquivoTmp);

      try
        ProcessPdf2htmlex.Execute;

        SimboloResultado := '+';
      except
        SimboloResultado := '*';
      end;

      ListBoxArquivoPdf.Items.Strings[Indice] := SimboloResultado + ' ' + StringListPdf.Strings[Indice];

      ProgressBarConversao.Position := Indice;

      Application.ProcessMessages;

      if ComboBoxPastaSaida.ItemIndex = 0 then begin
        PastaSaida := ExtractFilePath(StringListPdf.Strings[Indice]);
      end else begin
        PastaSaida := IncludeTrailingPathDelimiter(ComboBoxPastaSaida.Text);
      end;

      ArquivoHtml := PastaSaida + ExtractFileNameOnly(StringListPdf.Strings[Indice]) + '.html';

      MemoOperacao.Lines.Add('Arquivo destino ' + (Indice + 1).ToString + ': ' + ArquivoHtml);

      if CheckBoxSubstituirArquivosAutomaticamente.Checked then begin
        Copiar := true;
      end else begin
        if FileExists(ArquivoHtml) then begin
          if QuestionDlg('Atenção','Confirma substituição do arquivo ' + ArquivoHtml + '?', mtCustom, [mrYes, '&Sim', mrNo, '&Não'], '') = mrYes then begin
            Copiar := true;
          end else begin
            Copiar := false;
          end;
        end;
      end;

      if ComboBoxIncluirCodigo.ItemIndex > 0 then
        begin
          MemoOperacao.Lines.Add('Incluindo código...');

          IncluiCodigo(ProcessPdf2htmlex.CurrentDirectory + ArquivoTmp);

          MemoOperacao.Lines.Add('Código incluído.');
        end;

      if Copiar then begin
        try
          CopyFile(ProcessPdf2htmlex.CurrentDirectory + ArquivoTmp, ArquivoHtml);

          SimboloResultado := SimboloResultado + '+';
        except
          SimboloResultado := SimboloResultado + '*';
        end;
      end else begin
        SimboloResultado := SimboloResultado + '!';
      end;

      ListBoxArquivoPdf.Items.Strings[Indice] := SimboloResultado + ' ' + StringListPdf.Strings[Indice];

      try
        DeleteFile(ProcessPdf2htmlex.CurrentDirectory + ArquivoTmp);

        SimboloResultado := SimboloResultado + '+';
      except
        SimboloResultado := SimboloResultado + '*';
      end;

      ListBoxArquivoPdf.Items.Strings[Indice] := SimboloResultado + ' ' + StringListPdf.Strings[Indice];

      MemoOperacao.Lines.Add('---');
    end;

    MemoOperacao.Lines.Add('Fim: ' + DateTimeToStr(Now));

    ProcessPdf2htmlex.Free;

    ListBoxArquivoPdf.ItemIndex := -1;
    ListBoxArquivoPdf.Hint := '';
    LabelArquivoPdf.Caption :=  'Conversão concluída.';
  end;
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

