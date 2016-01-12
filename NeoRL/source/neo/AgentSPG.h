#pragma once

#include "ComparisonSparseCoder.h"
#include "PredictorSwarm.h"
#include "ImageWhitener.h"

namespace neo {
	/*!
	\brief Policy gradient agent
	*/
	class AgentSPG {
	public:
		/*!
		\brief Layer desc
		*/
		struct LayerDesc {
			/*!
			\brief Size of layer
			*/
			cl_int2 _size;

			/*!
			\brief Radii
			*/
			cl_int _feedForwardRadius, _recurrentRadius, _lateralRadius, _feedBackRadius, _predictiveRadius;

			//!@{
			/*!
			\brief Sparse coder parameters
			*/
			cl_float _scWeightAlpha;
			cl_float _scWeightRecurrentAlpha;
			cl_float _scWeightLambda;
			cl_float _scActiveRatio;
			cl_float _scBoostAlpha;
			//!@}

			//!@{
			/*!
			\brief RL
			*/
			cl_float2 _alpha;
			cl_float _gamma;
			cl_float2 _lambda;
			cl_float _noise;
			cl_float _reg;
			//!@}

			/*!
			\brief Initialize defaults
			*/
			LayerDesc()
				: _size({ 8, 8 }),
				_feedForwardRadius(5), _recurrentRadius(5), _lateralRadius(5), _feedBackRadius(6), _predictiveRadius(6),
				_scWeightAlpha(0.0001f), _scWeightRecurrentAlpha(0.0001f), _scWeightLambda(0.96f),
				_scActiveRatio(0.05f), _scBoostAlpha(0.01f),
				_alpha({ 10.0f, 0.01f }), _gamma(0.98f), _lambda({ 0.96f, 0.96f }), _noise(0.0f), _reg(0.01f)
			{}
		};

		/*!
		\brief Layer
		*/
		struct Layer {
			//!@{
			/*!
			\brief Sparse coder and predictor
			*/
			ComparisonSparseCoder _sc;
			PredictorSwarm _pred;
			//!@}

			//!@{
			/*!
			\brief For prediction reward determination
			*/
			cl::Image2D _predReward;
			cl::Image2D _propagatedPredReward;
			//!@}
		};

	private:
		/*!
		\brief Store input size
		*/
		cl_int2 _inputSize;

		/*!
		\brief Store action size
		*/
		cl_int2 _actionSize;

		//!@{
		/*!
		\brief Layers and descs
		*/
		std::vector<Layer> _layers;
		std::vector<LayerDesc> _layerDescs;
		//!@}

		//!@{
		/*!
		\brief Kernels for hierarchy
		*/
		cl::Kernel _predictionRewardKernel;
		cl::Kernel _predictionRewardPropagationKernel;
		//!@}

		//!@{
		/*!
		\brief Input whiteners
		*/
		ImageWhitener _inputWhitener;
		ImageWhitener _actionWhitener;
		//!@}

	public:
		//!@{
		/*!
		\brief Whitening parameters
		*/
		cl_int _whiteningKernelRadius;
		cl_float _whiteningIntensity;
		//!@}

		/*!
		\brief Initialize defaults
		*/
		AgentSPG()
			: _whiteningKernelRadius(1),
			_whiteningIntensity(1024.0f)
		{}

		/*!
		\brief Create a comparison sparse coder with random initialization
		Requires the compute system, program with the NeoRL kernels, and initialization information.
		*/
		void createRandom(sys::ComputeSystem &cs, sys::ComputeProgram &program,
			cl_int2 inputSize, cl_int2 actionSize, const std::vector<LayerDesc> &layerDescs,
			cl_float2 initWeightRange,
			std::mt19937 &rng);

		//!@{
		/*!
		\brief Simulation step of hierarchy
		*/
		void simStep(sys::ComputeSystem &cs, float reward, const cl::Image2D &input, std::mt19937 &rng, bool learn = true, bool useInputWhitener = true, bool binaryOutput = false) {
			simStep(cs, reward, input, _layers.front()._pred.getHiddenStates()[_front], rng, learn, useInputWhitener, binaryOutput);
		}

		void simStep(sys::ComputeSystem &cs, float reward, const cl::Image2D &input, const cl::Image2D &targetActions, std::mt19937 &rng, bool learn = true, bool useInputWhitener = true, bool binaryOutput = false);
		//!@}

		/*!
		\brief Clear working memory
		*/
		void clearMemory(sys::ComputeSystem &cs);

		/*!
		\brief Write to stream
		*/
		void writeToStream(sys::ComputeSystem &cs, std::ostream &os) const;

		/*!
		\brief Read from stream
		*/
		void readFromStream(sys::ComputeSystem &cs, sys::ComputeProgram &program, std::istream &is);

		/*!
		\brief Get number of layers
		*/
		size_t getNumLayers() const {
			return _layers.size();
		}

		/*!
		\brief Get access to a layer
		*/
		const Layer &getLayer(int index) const {
			return _layers[index];
		}

		/*!
		\brief Get access to a layer desc
		*/
		const LayerDesc &getLayerDescs(int index) const {
			return _layerDescs[index];
		}

		/*!
		\brief Get exploratory action
		*/
		const cl::Image2D &getExploratoryAction() const {
			return _layers.front()._pred.getHiddenStates()[_back];
		}

		/*!
		\brief Get input whitener
		*/
		const ImageWhitener &getInputWhitener() const {
			return _inputWhitener;
		}

		/*!
		\brief Get action whitener
		*/
		const ImageWhitener &getActionWhitener() const {
			return _actionWhitener;
		}
	};
}