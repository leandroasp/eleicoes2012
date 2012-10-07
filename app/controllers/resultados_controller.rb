require "rubygems"
require "nokogiri"
require "net/http"

class ResultadosController < ApplicationController
  #caches_action :index
  #expire_action :action => :index

  def index
  end

  def uf
    turnos = {"1turno" => 1, "2turno" => 2}
    @turno = turnos[params[:turno]].to_s
    @estado = params[:estado].to_s
  end

  def city
    turnos = {"1turno" => 1, "2turno" => 2}
    @turno = turnos[params[:turno]].to_s
    @estado = params[:estado].to_s
  end

  def show
    turnos = {"1turno" => 1, "2turno" => 2}

    @turno = turnos[params[:turno]].to_s
    @estado = params[:estado].to_s
    @cidade = params[:cidade].to_s

    if (Rails.cache.read("expires_#{@turno}#{@estado}#{@cidade}") == nil || Time.now > Rails.cache.read("expires_#{@turno}#{@estado}#{@cidade}"))
      @resultado = JSON.parse(Net::HTTP.get URI.parse("http://divulga.tse.jus.br/2012/divulgacao/oficial/47/dadosdivweb/#{@estado}/#{@estado}#{@cidade}-0011-e000473-w.js"))
      Rails.cache.write("resultado_#{@turno}#{@estado}#{@cidade}", @resultado)
      Rails.cache.write("expires_#{@turno}#{@estado}#{@cidade}", Time.now + 60.seconds)
    else
      @resultado = Rails.cache.read("resultado_#{@turno}#{@estado}#{@cidade}")
    end

    @candidatos = []
    @resultado['cand'].each do |votavel|
      c = {}
      c['totalVotos'] = votavel['v'].to_i
      c['numero'] = votavel['n'].to_s
      c['percent'] = votavel['v'].to_f / @resultado['tv'].to_i
      c['nome'] = votavel['nm'].to_s
      c['partido'] = votavel['cc'].to_s.gsub(/\s-.*$/,'')
      c['descricaoSituacao'] = ''
      c['situacao'] = (votavel['e'].to_s == 'n' ? '' : 'eleito')
      @candidatos << c
    end

    @votos_pendente = @resultado['ena'].to_i

    if @votos_pendente == 0
      eleitos = @candidatos.map { |c| c if c['situacao'] == 'eleito'}.compact.sort_by { |c| c['totalVotos'] }.reverse
      nao_eleitos = (@candidatos - eleitos).sort_by { |c| c['totalVotos'] }.reverse
      @candidatos = eleitos + nao_eleitos
    else
      @candidatos = @candidatos.sort_by { |c| c['totalVotos'] }.reverse
    end

    @eleitorado_perc_a = @resultado['ena'].to_f / @resultado['e'].to_i
    @eleitorado_perc_n = (@resultado['e'].to_f - @resultado['ena'].to_f) / @resultado['e'].to_i
    @apurado_perc_a = @resultado['ea'].to_f / (@resultado['ea'].to_i + @resultado['c'].to_i)
    @apurado_perc_c = @resultado['c'].to_f / (@resultado['a'].to_i + @resultado['c'].to_i)

    @votos_perc_b = @resultado['vb'].to_f / @resultado['tv'].to_i
    @votos_perc_n = @resultado['vn'].to_f / @resultado['tv'].to_i
    @votos_perc_p = @votos_pendente.to_f / @resultado['tv'].to_f
    @votos_perc_v = @resultado['vv'].to_f / @resultado['tv'].to_i

    @graph_apuracao = Gchart.pie(
      :size => '275x160',
      :labels => ['Apurados', 'Nao apurados'],
      :data => [
        @resultado['ea'].to_i,
        @resultado['e'].to_i - @resultado['ea'].to_i
      ]
    )
    @graph_comparecimento = Gchart.pie(
      :size => '275x160',
      :labels => ['Abstencao', 'Comparecimento'],
      :data => [@resultado['a'].to_i, @resultado['c'].to_i]
    )
    @graph_votos = Gchart.pie(
      :size => '275x160',
      :labels => ['Em branco', 'Nulos', 'Pendentes', 'Validos'],
      :data => [
        @resultado['vb'].to_i,
        @resultado['vn'].to_i,
        @votos_pendente,
        @resultado['vv'].to_i
      ]
    )

    @eleitorado = @resultado['e']
    @apurados = @resultado['ea']
    @comparecimento = @resultado['c']
    @abstencao = @resultado['a']
    @vb = @resultado['vb']
    @vn = @resultado['vn']
    @vv = @resultado['vv']
  end

  #private
    #def format_number(value, decimal = 1)
    #  format("%.#{decimal}f", 100 * value)
    #end

end
