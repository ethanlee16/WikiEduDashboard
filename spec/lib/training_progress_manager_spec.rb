require 'rails_helper'

describe TrainingProgressManager do
  let(:user)     { create(:user) }
  # first and last slide
  let(:t_module) { TrainingModule.all.first }
  let(:slides)   { [t_module.slides.first, t_module.slides.last] }
  let(:slide)    { slides.first }
  let(:last_slide_completed) { slides.first.slug }
  let(:tmu)      { create(:training_modules_users, user_id: user.try(:id), training_module_id: t_module.id, last_slide_completed: last_slide_completed, completed_at: completed_at ) }
  let(:completed_at) { nil }

  before  { tmu }
  subject { described_class.new(user, t_module, slide) }

  describe '#slide_completed?' do
    context 'tmu is nil' do
      let(:tmu) { nil }
      it 'returns false' do
        expect(subject.slide_completed?).to eq(false)
      end
    end

    context 'last slide completed is nil' do
      let(:last_slide_completed) { nil }
      it 'returns false' do
        expect(subject.slide_completed?).to eq(false)
      end
    end

    context 'last slide completed is first slide' do
      it 'returns true' do
        expect(subject.slide_completed?).to eq(true)
      end
    end

    context 'last slide completed is first slide; slide in question is last slide' do
      let(:last_slide_completed) { slides.first.slug }
      let(:slide) { slides.last }
      it 'returns false' do
        expect(subject.slide_completed?).to eq(false)
      end
    end
  end

  describe '#slide_enabled?' do
    context 'user (current_user) is nil (if user is not signed in, all of training is available' do
      let(:user) { nil }
      it 'returns true' do
        expect(subject.slide_enabled?).to eq(true)
      end
    end

    context 'tmu is nil (user has not started module yet)' do
      let(:tmu) { nil }
      context 'slide is first slide' do
        it 'returns true' do
          expect(subject.slide_enabled?).to eq(true)
        end
      end
      context 'slide is not first slide' do
        let(:slide) { slides.last }
        it 'returns false' do
          expect(subject.slide_enabled?).to eq(false)
        end
      end
    end

    context 'slide is first slide; no slides viewed for this module' do
      let(:last_slide_completed) { nil }
      it 'returns true' do
        expect(subject.slide_enabled?).to eq(true)
      end
    end

    context 'slide has been seen' do
      let(:last_slide_completed) { slides.first.slug }
      let(:slide) { slides.first }
      it 'returns true' do
        expect(subject.slide_enabled?).to eq(true)
      end
    end

    context 'slide has not been seen' do
      let(:last_slide_completed) { slides.first.slug }
      let(:slide) { slides.last }
      it 'returns false' do
        expect(subject.slide_enabled?).to eq(false)
      end
    end
  end

  describe '#module_completed?' do
    context 'completed_at is nil for tmu' do
      it 'returns false' do
        expect(subject.module_completed?).to eq(false)
      end
    end

    context 'completed_at is present for tmu' do
      let(:completed_at) { Time.now }
      it 'returns true' do
        expect(subject.module_completed?).to eq(true)
      end
    end
  end

  describe '#module_progress' do
    context 'user is nil' do
      let(:user) { nil }
      it 'returns nil' do
        expect(subject.module_progress).to be_nil
      end
    end

    context 'completed' do
      let(:completed_at) { Time.now }
      it 'returns "completed"' do
        expect(subject.module_progress).to eq('Completed')
      end
    end

    context 'not started' do
      let(:completed_at) { nil }
      context '0 of 35' do
        # module has 35 slides
        let(:last_slide_completed) { nil }
        it 'returns empty string' do
          expect(subject.module_progress).to eq('')
        end
      end
    end

    context 'partial completion' do
      context 'round down' do
        let(:completed_at) { nil }
        context '12 of 35' do
          # module has 35 slides
          let(:last_slide_completed) { t_module.slides[11].slug }
          it 'returns 34%' do
            expect(subject.module_progress).to eq('34%')
          end
        end
      end

      context 'round up' do
        let(:completed_at) { nil }
        context '23 of 35' do
          # module has 35 slides
          let(:last_slide_completed) { t_module.slides[22].slug }
          it 'returns 66%' do
            expect(subject.module_progress).to eq('66%')
          end
        end
      end
    end
  end
end