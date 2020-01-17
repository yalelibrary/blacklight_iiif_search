require 'iiif_search_shared'
RSpec.describe BlacklightIiifSearch::IiifSearchResponse do
  include_context 'iiif_search_shared'

  let(:iiif_search_service) do
    controller.search_service_class.new(config: blacklight_config,
                                        user_params: iiif_search.solr_params)
  end
  let(:solr_response) { iiif_search_service.search_results.first }
  let(:iiif_search_response) do
    described_class.new(solr_response, parent_document, controller)
  end

  describe 'class' do
    it 'is a IiifSearchResponse' do
      expect(iiif_search_response.class).to eq(described_class)
    end
  end

  describe '#annotation_list' do
    subject { iiif_search_response.annotation_list }

    it 'returns an OrderedHash' do
      expect(subject.class).to eq(IIIF::OrderedHash)
    end

    it 'has the correct content' do
      expect(subject['@id']).not_to be_falsey
      expect(subject['@type']).to eq('sc:AnnotationList')
      expect(subject['resources']).not_to be_blank
      expect(subject['within']).not_to be_blank
      expect(subject['hits']).not_to be_blank
    end

    let(:hit) { subject['hits'].first }
    it 'has properly formatted search:Hit' do
      expect(hit[:@type]).to eq('search:Hit')
      expect(hit[:annotations].first).to eq(subject['resources'].first['@id'])
    end
  end

  describe '#resources' do
    subject { iiif_search_response.resources }
    it 'returns an array of IiifSearchAnnotation objects' do
      expect(subject.length).to eq(2)
      expect(subject.first.class).to eq(IIIF::Presentation::Annotation)
    end
  end

  describe '#clean_params' do
    subject { iiif_search_response.clean_params }
    it 'returns an array of acceptable parameters' do
      expect(subject).to include('q')
      expect(subject).not_to include('date')
    end
  end

  # TODO: fix ActionController::UrlGenerationError:
  # No route matches {:action=>"iiif_search", :controller=>"catalog", "page"=>100, "q"=>"teachers"},
  # missing required keys: [:solr_document_id]
  # this method calls solr_document_iiif_search_url
  # missing :solr_document_id only seems to be an issue with the spec
  describe '#paged_url' do
    it 'returns a solr_document URL with the page param'
    # expect(iiif_search_response.paged_url(100)).to include('page=100')
  end

  describe '#within' do
    subject { iiif_search_response.within }
    it 'returns a IIIF::Presentation::Layer object' do
      expect(subject.class).to eq(IIIF::Presentation::Layer)
      expect(subject['ignored']).to include('date')
    end
  end
end
